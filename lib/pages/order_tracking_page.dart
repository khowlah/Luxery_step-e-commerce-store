import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final order = OrderModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(order),
                const SizedBox(height: 30),
                _buildStatusStepper(order),
                const SizedBox(height: 30),
                _buildOrderDetails(order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderModel order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Placed on ${order.timestamp.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(OrderModel order) {
    return Column(
      children: [
        _buildStep(
          title: 'Pending',
          subtitle: 'Your order is awaiting approval',
          icon: Icons.hourglass_empty,
          isActive: true,
          isCompleted: order.status == OrderStatus.processing || order.status == OrderStatus.delivered,
        ),
        _buildConnector(isCompleted: order.status == OrderStatus.processing || order.status == OrderStatus.delivered),
        _buildStep(
          title: 'Processing',
          subtitle: 'We are preparing your order',
          icon: Icons.sync,
          isActive: order.status == OrderStatus.processing || order.status == OrderStatus.delivered,
          isCompleted: order.status == OrderStatus.delivered,
        ),
        _buildConnector(isCompleted: order.status == OrderStatus.delivered),
        _buildStep(
          title: 'Delivered',
          subtitle: 'Order has been delivered',
          icon: Icons.check_circle_outline,
          isActive: order.status == OrderStatus.delivered,
          isCompleted: order.status == OrderStatus.delivered,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color color = isCompleted ? Colors.green : (isActive ? Colors.deepPurple : Colors.grey);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(isCompleted ? Icons.check : icon, color: color, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 19),
      height: 30,
      width: 2,
      color: isCompleted ? Colors.green : Colors.grey[300],
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item),
                  const Text('x1'),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
