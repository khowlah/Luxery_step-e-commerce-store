import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  processing,
  delivered,
}

class OrderModel {
  final String id;
  final String userId;
  final List<String> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: List<String>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: _parseStatus(data['status']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
        return OrderStatus.delivered;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}
