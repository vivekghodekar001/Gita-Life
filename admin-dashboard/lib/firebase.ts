import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyAraydbR82KyKnSu2qDpWGiLlnC4sKs-5g",
    authDomain: "gita-life-b713a.firebaseapp.com",
    projectId: "gita-life-b713a",
    storageBucket: "gita-life-b713a.firebasestorage.app",
    messagingSenderId: "273830910501",
    appId: "1:273830910501:web:0a2dad27714146a2883dcc",
    measurementId: "G-3BT743ZZK3"
};

// Initialize Firebase only if it hasn't been initialized yet
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

export { app, auth, db, storage };
