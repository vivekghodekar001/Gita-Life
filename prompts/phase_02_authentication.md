# Phase 02 — Authentication
**Estimated Time: 2–3 days**

## Prompt for Google Antigravity / AI IDE

```
Implement complete authentication for GitaLife Flutter app using Firebase Auth.

Screens to implement:
1. LoginScreen (/login) — Email/password login with form validation
2. RegisterScreen (/register) — Full registration: name, roll number, email, phone, password
3. OtpScreen (/otp) — Phone number OTP verification using Firebase Phone Auth
4. ForgotPasswordScreen (/forgot-password) — Send password reset email

AuthService implementation:
- registerWithEmail: Create Firebase user, save UserModel to /users/{uid} in Firestore
- loginWithEmail: Firebase email/password sign in
- sendPhoneOtp: Firebase verifyPhoneNumber with timeout 60s
- verifyPhoneOtp: PhoneAuthCredential signInWithCredential
- resetPassword: sendPasswordResetEmail
- getUserProfile: Fetch UserModel from /users/{uid}
- updateFcmToken: Update FCM token in user document
- logout: signOut + clear local data

UserModel fields: uid, fullName, rollNumber, email, phoneNumber, profilePhotoUrl, role (student/admin), status (pending/active/suspended), enrollmentDate, fcmToken, createdAt, updatedAt

Router redirect logic:
- Unauthenticated users → /login
- Authenticated users trying to access auth routes → /home
- Users with status 'pending' → show waiting for approval screen
- Users with status 'suspended' → show suspended screen

Add form validation for all fields. Show loading indicators during async operations. Handle errors with SnackBar messages.
```

## Success Criteria
- [ ] User can register with email/password
- [ ] User can log in with email/password
- [ ] Phone OTP flow works end-to-end
- [ ] Password reset email is sent
- [ ] Auth state persists across app restarts
- [ ] Unauthenticated users are redirected to login

## Dependencies
- Phase 01 (project setup)
- Firebase project created with Auth enabled
- Firestore database created
