// Firebase Configuration
// Gift Wave Firebase Project
const firebaseConfig = {
    apiKey: "AIzaSyBJxWGZivRYvy-V79hV15-DzbOOUiNkEgk",
    authDomain: "gift-wave.firebaseapp.com",
    projectId: "gift-wave",
    storageBucket: "gift-wave.firebasestorage.app",
    messagingSenderId: "202603073767",
    appId: "1:202603073767:ios:6886f2b53a78e668745242"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Initialize Firebase services
const auth = firebase.auth();
const db = firebase.firestore();

// Enable Firestore offline persistence
db.enablePersistence()
    .catch((err) => {
        if (err.code == 'failed-precondition') {
            console.log('Multiple tabs open, persistence can only be enabled in one tab at a time.');
        } else if (err.code == 'unimplemented') {
            console.log('The current browser does not support persistence.');
        }
    });

console.log('Firebase initialized successfully'); 