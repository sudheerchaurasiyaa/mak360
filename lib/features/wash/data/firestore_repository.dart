import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../domain/app_models.dart';
import '../domain/wash_service.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get uid => _auth.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get profileRef =>
      _firestore.collection('users').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> profile() =>
      profileRef.snapshots();

  Future<void> updateProfile({
    required String displayName,
    required String phone,
    required String address,
  }) => profileRef.update({
    'displayName': displayName.trim(),
    'phone': phone.trim(),
    'address': address.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Stream<List<Vehicle>> vehicles() =>
      profileRef.collection('vehicles').snapshots().map((snapshot) {
        final items = snapshot.docs.map(Vehicle.fromDoc).toList();
        items.sort((a, b) {
          if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
          return a.number.compareTo(b.number);
        });
        return items;
      });

  Future<void> saveVehicle({
    String? id,
    required String number,
    required String type,
    required String label,
    required bool isDefault,
  }) async {
    final collection = profileRef.collection('vehicles');
    final target = id == null ? collection.doc() : collection.doc(id);
    final batch = _firestore.batch();
    if (isDefault) {
      final existing = await collection
          .where('isDefault', isEqualTo: true)
          .get();
      for (final doc in existing.docs) {
        if (doc.id != target.id) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
    }
    batch.set(target, {
      'ownerId': uid,
      'number': number.trim().toUpperCase(),
      'type': type,
      'label': label.trim(),
      'isDefault': isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
      if (id == null) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> deleteVehicle(String id) =>
      profileRef.collection('vehicles').doc(id).delete();

  Stream<List<WashBooking>> customerBookings() => _firestore
      .collection('bookings')
      .where('customerId', isEqualTo: uid)
      .snapshots()
      .map(_sortedBookings);

  Stream<List<WashBooking>> ownerBookings() =>
      _firestore.collection('bookings').snapshots().map(_sortedBookings);

  List<WashBooking> _sortedBookings(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final bookings = snapshot.docs.map(WashBooking.fromDoc).toList();
    bookings.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return bookings;
  }

  Future<String> createBooking({
    required Vehicle vehicle,
    required WashService service,
    required DateTime scheduledAt,
    required bool pickupRequested,
    required String pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    required String notes,
  }) async {
    final profile =
        (await profileRef.get()).data() ?? const <String, dynamic>{};
    final ref = _firestore.collection('bookings').doc();
    await ref.set({
      'customerId': uid,
      'customerName':
          profile['displayName'] as String? ??
          _auth.currentUser?.displayName ??
          '',
      'customerPhone': profile['phone'] as String? ?? '',
      'vehicleId': vehicle.id,
      'vehicleNumber': vehicle.number,
      'vehicleType': vehicle.type,
      'serviceName': service.name,
      'price': service.price,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': 'requested',
      'pickupRequested': pickupRequested,
      'pickupAddress': pickupRequested ? pickupAddress.trim() : '',
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'notes': notes.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> cancelBooking(String bookingId) =>
      _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateBookingStatus(String bookingId, String status) =>
      _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Stream<List<ChatMessage>> messages(String bookingId) => _firestore
      .collection('bookings')
      .doc(bookingId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(ChatMessage.fromDoc).toList());

  Future<void> sendMessage(String bookingId, String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .add({
          'senderId': uid,
          'text': cleaned,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Map<String, dynamic>>> notifications() => _firestore
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      );

  Future<void> markNotificationRead(String id) =>
      profileRef.collection('notifications').doc(id).update({'read': true});

  Future<void> registerMessagingToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null) await _saveToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
    } catch (_) {
      // Notifications are optional at runtime; auth and bookings must still work.
    }
  }

  Future<void> _saveToken(String token) =>
      profileRef.collection('fcmTokens').doc(token).set({
        'token': token,
        'platform': 'mobile',
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
