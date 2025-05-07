// order_item_card.dart
import 'package:flutter/material.dart';

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderItemCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Image.asset(order['image'],
            width: 60, height: 60, fit: BoxFit.cover),
        title: Text(order['productName'],
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order['price'], style: TextStyle(color: Colors.green)),
            Text('Date: ${order['date']}'),
            Text('Status: ${order['status']}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(order['status']))),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Shipped':
        return Colors.blue;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
