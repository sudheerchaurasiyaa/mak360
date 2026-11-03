import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.number,
    required this.type,
    required this.label,
    required this.isDefault,
  });

  final String id;
  final String number;
  final String type;
  final String label;
  final bool isDefault;

  @override
  bool operator ==(Object other) => other is Vehicle && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Vehicle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Vehicle(
      id: doc.id,
      number: data['number'] as String? ?? '',
      type: data['type'] as String? ?? '',
      label: data['label'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }
}

class WashBooking {
  const WashBooking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.serviceName,
    required this.price,
    required this.scheduledAt,
    required this.status,
    required this.pickupRequested,
    required this.pickupAddress,
    required this.notes,
    this.pickupLatitude,
    this.pickupLongitude,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleType;
  final String serviceName;
  final int price;
  final DateTime scheduledAt;
  final String status;
  final bool pickupRequested;
  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String notes;
  final DateTime? createdAt;

  factory WashBooking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return WashBooking(
      id: doc.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      vehicleNumber: data['vehicleNumber'] as String? ?? '',
      vehicleType: data['vehicleType'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'requested',
      pickupRequested: data['pickupRequested'] as bool? ?? false,
      pickupAddress: data['pickupAddress'] as String? ?? '',
      pickupLatitude: (data['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (data['pickupLongitude'] as num?)?.toDouble(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? sentAt;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

const bookingStatuses = <String>[
  'requested',
  'confirmed',
  'pickup_assigned',
  'picked_up',
  'washing',
  'ready',
  'returning',
  'completed',
  'cancelled',
];

String statusLabel(String status) => status
    .split('_')
    .map(
      (part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');
