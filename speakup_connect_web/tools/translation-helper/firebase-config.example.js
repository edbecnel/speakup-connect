// Copy to firebase-config.js and fill in your Firebase web app config.
//
// Firebase Console → Project settings → General → Your apps → Web app → Config
// https://console.firebase.google.com/project/speakup-connect-891dd/settings/general
//
// Replace YOUR_API_KEY (AIzaSy…) and YOUR_WEB_APP_ID (1:…:web:…) only.
// Do NOT put your OpenAI key (sk-…) here — that goes in functions/.env
window.FIREBASE_CONFIG = {
  apiKey: 'YOUR_API_KEY',
  authDomain: 'speakup-connect-891dd.firebaseapp.com',
  projectId: 'speakup-connect-891dd',
  storageBucket: 'speakup-connect-891dd.firebasestorage.app',
  messagingSenderId: '212080957929',
  appId: 'YOUR_WEB_APP_ID',
};

/** Set true only when running `firebase emulators:start --only functions` locally. */
window.USE_FUNCTIONS_EMULATOR = false;

/** Required for org admins and translation moderators (not platform super_admin). */
window.ORGANIZATION_ID = 'monhs-ph-001';
