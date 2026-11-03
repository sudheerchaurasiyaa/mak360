const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {setGlobalOptions} = require('firebase-functions/v2');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');

initializeApp();
setGlobalOptions({region: 'asia-south1', maxInstances: 10});

const db = getFirestore();

async function userTokens(uid) {
  const snapshot = await db.collection('users').doc(uid).collection('fcmTokens').get();
  return snapshot.docs.map((doc) => doc.id);
}

async function ownerIds() {
  const snapshot = await db.collection('users').where('role', '==', 'owner').get();
  return snapshot.docs.map((doc) => doc.id);
}

async function notifyUser(uid, title, body, data = {}) {
  const notificationRef = db.collection('users').doc(uid).collection('notifications').doc();
  await notificationRef.set({title, body, data, read: false, createdAt: FieldValue.serverTimestamp()});
  const tokens = await userTokens(uid);
  if (tokens.length === 0) return;
  const result = await getMessaging().sendEachForMulticast({
    tokens: tokens.slice(0, 500),
    notification: {title, body},
    data: Object.fromEntries(Object.entries(data).map(([key, value]) => [key, String(value)])),
    android: {priority: 'high'},
  });
  const invalid = [];
  result.responses.forEach((response, index) => {
    if (!response.success && ['messaging/invalid-registration-token', 'messaging/registration-token-not-registered'].includes(response.error?.code)) {
      invalid.push(tokens[index]);
    }
  });
  await Promise.all(invalid.map((token) => db.collection('users').doc(uid).collection('fcmTokens').doc(token).delete()));
}

exports.onBookingCreated = onDocumentCreated('bookings/{bookingId}', async (event) => {
  const booking = event.data?.data();
  if (!booking) return;
  const owners = await ownerIds();
  await Promise.all(owners.map((uid) => notifyUser(
    uid,
    'New wash request',
    `${booking.customerName || 'A customer'} requested ${booking.serviceName}${booking.pickupRequested ? ' with pickup' : ''}.`,
    {type: 'booking', bookingId: event.params.bookingId},
  )));
});

exports.onBookingUpdated = onDocumentUpdated('bookings/{bookingId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after || before.status === after.status) return;
  const label = String(after.status).split('_').map((part) => part.charAt(0).toUpperCase() + part.slice(1)).join(' ');
  await notifyUser(
    after.customerId,
    'Wash request updated',
    `${after.vehicleNumber}: ${label}`,
    {type: 'booking', bookingId: event.params.bookingId},
  );
});

exports.onChatMessageCreated = onDocumentCreated('bookings/{bookingId}/messages/{messageId}', async (event) => {
  const message = event.data?.data();
  if (!message) return;
  const booking = (await db.collection('bookings').doc(event.params.bookingId).get()).data();
  if (!booking) return;
  const recipients = message.senderId === booking.customerId ? await ownerIds() : [booking.customerId];
  await Promise.all(recipients.map((uid) => notifyUser(
    uid,
    'New chat message',
    String(message.text).slice(0, 120),
    {type: 'chat', bookingId: event.params.bookingId},
  )));
});
