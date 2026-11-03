const {initializeApp, applicationDefault} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getAuth} = require('firebase-admin/auth');

const email = process.argv[2];
if (!email) {
  console.error('Usage: npm run set-owner -- owner@example.com');
  process.exit(1);
}

initializeApp({credential: applicationDefault(), projectId: 'mak360'});

async function main() {
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, {owner: true});
  await getFirestore().collection('users').doc(user.uid).set({
    uid: user.uid,
    role: 'owner',
    displayName: user.displayName || 'MAK360 Owner',
    email: user.email,
    phone: user.phoneNumber || '',
    address: '',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
  console.log(`Owner role granted to ${email} (${user.uid}). Sign out and back in to refresh claims.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
