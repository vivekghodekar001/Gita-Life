import { after, before, beforeEach, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, getDoc, getDocs, collection, query, where } from 'firebase/firestore';
import { ref, uploadBytes, deleteObject } from 'firebase/storage';

let env;
const profile = (uid, role = 'student', status = 'pending') => ({ uid, role, status });
const db = uid => env.authenticatedContext(uid).firestore();
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-gita-life-tests',
    firestore: { rules: readFileSync('firestore.rules', 'utf8') },
    storage: { rules: readFileSync('storage.rules', 'utf8') },
  });
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async context => {
    const store = context.firestore();
    await Promise.all([
      setDoc(doc(store, 'users/admin'), profile('admin', 'admin', 'active')),
      setDoc(doc(store, 'users/counselor'), profile('counselor', 'counselor', 'active')),
      setDoc(doc(store, 'users/alice'), { ...profile('alice', 'student', 'active'), counselorUid: 'counselor' }),
      setDoc(doc(store, 'users/bob'), { ...profile('bob', 'student', 'active'), counselorUid: 'someone-else' }),
      setDoc(doc(store, 'users/pending'), profile('pending')),
      setDoc(doc(store, 'users/suspended-admin'), profile('suspended-admin', 'admin', 'suspended')),
      setDoc(doc(store, 'attendance_sessions/open'), { isLocked: false }),
      setDoc(doc(store, 'attendance_sessions/locked'), { isLocked: true }),
    ]);
  });
});
after(async () => { if (env) await env.cleanup(); });

test('registration permits pending students and rejects self-appointed privileges', async () => {
  const store = db('new-user');
  await assertFails(setDoc(doc(store, 'users/new-user'), profile('new-user', 'admin', 'active')));
  await assertFails(setDoc(doc(store, 'users/new-user'), profile('new-user', 'student', 'active')));
  await assertFails(setDoc(doc(store, 'users/new-user'), { ...profile('new-user'), counselorUid: 'counselor' }));
  await assertFails(setDoc(doc(store, 'users/new-user'), profile('another-user')));
  await assertSucceeds(setDoc(doc(store, 'users/new-user'), profile('new-user')));
});
test('profile owners can edit personal fields but cannot approve or promote themselves', async () => {
  const own = doc(db('pending'), 'users/pending');
  await assertSucceeds(updateDoc(own, { fullName: 'New Name', fcmToken: 'token' }));
  for (const data of [{ status: 'active' }, { role: 'admin' }, { attendanceScore: 999 }, { uid: 'admin' }]) {
    await assertFails(updateDoc(own, data));
  }
  await assertSucceeds(updateDoc(doc(db('admin'), 'users/pending'), { status: 'active' }));
  await assertFails(updateDoc(doc(db('suspended-admin'), 'users/pending'), { status: 'active' }));
});
test('counselors can query assigned users without reading all profiles', async () => {
  const store = db('counselor');
  await assertSucceeds(getDocs(query(collection(store, 'users'), where('counselorUid', '==', 'counselor'))));
  await assertSucceeds(getDoc(doc(store, 'users/alice')));
  await assertFails(getDoc(doc(store, 'users/bob')));
  await assertFails(getDocs(collection(store, 'users')));
  await assertSucceeds(updateDoc(doc(store, 'users/alice'), { attendanceScore: 3 }));
  await assertFails(updateDoc(doc(store, 'users/bob'), { attendanceScore: 3 }));
  await assertFails(updateDoc(doc(store, 'users/alice'), { role: 'admin' }));
});
test('counselors can mark only assigned devotees and cannot retarget a record', async () => {
  const store = db('counselor');
  const record = { devoteeId: 'alice', sessionId: 'open', markedBy: 'counselor', status: 'Present' };
  await assertSucceeds(setDoc(doc(store, 'attendance/alice_open'), record));
  await assertFails(setDoc(doc(store, 'attendance/bob_open'), { ...record, devoteeId: 'bob' }));
  await assertFails(updateDoc(doc(store, 'attendance/alice_open'), { devoteeId: 'bob' }));
  await assertFails(updateDoc(doc(store, 'attendance/alice_open'), { sessionId: 'other' }));
});
test('locked legacy attendance rejects new records as well as updates', async () => {
  const store = db('admin');
  await assertFails(setDoc(doc(store, 'attendance_records/locked'), { sessionId: 'locked', studentUid: 'alice' }));
  const record = doc(store, 'attendance_records/open');
  await assertSucceeds(setDoc(record, { sessionId: 'open', studentUid: 'alice', status: 'present' }));
  await assertFails(updateDoc(record, { sessionId: 'locked' }));
  await assertSucceeds(updateDoc(doc(store, 'attendance_sessions/open'), { isLocked: true }));
  await assertFails(updateDoc(record, { status: 'absent' }));
});
test('profile uploads are restricted to the owner, MIME type and size', async () => {
  const storage = env.authenticatedContext('alice').storage();
  const metadata = { contentType: 'image/jpeg' };
  await assertSucceeds(uploadBytes(ref(storage, 'profile_photos/alice.jpg'), new Uint8Array(8), metadata));
  await assertFails(uploadBytes(ref(storage, 'profile_photos/bob.jpg'), new Uint8Array(8), metadata));
  await assertFails(uploadBytes(ref(storage, 'profile_photos/alice.jpg'), new Uint8Array(8), { contentType: 'text/plain' }));
  await assertFails(uploadBytes(ref(storage, 'profile_photos/alice.jpg'), new Uint8Array(5 * 1024 * 1024), metadata));
  await assertFails(deleteObject(ref(env.authenticatedContext('bob').storage(), 'profile_photos/alice.jpg')));
  await assertSucceeds(deleteObject(ref(storage, 'profile_photos/alice.jpg')));
});
test('only active administrators can write shared audio and lecture files', async () => {
  for (const folder of ['audio', 'lectures']) {
    for (const uid of ['alice', 'pending', 'suspended-admin']) {
      await assertFails(uploadBytes(ref(env.authenticatedContext(uid).storage(), `${folder}/track.bin`), new Uint8Array(8)));
    }
    await assertSucceeds(uploadBytes(ref(env.authenticatedContext('admin').storage(), `${folder}/track.bin`), new Uint8Array(8)));
  }
});
test('unauthenticated users cannot read profiles or upload media', async () => {
  const context = env.unauthenticatedContext();
  await assertFails(getDoc(doc(context.firestore(), 'users/alice')));
  await assertFails(uploadBytes(ref(context.storage(), 'audio/track.bin'), new Uint8Array(8)));
});
