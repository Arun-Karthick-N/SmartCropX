import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class OrderPlacedPage extends StatefulWidget {
  @override
  _OrderPlacedPageState createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You must be logged in to view orders'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Check if the user is a farmer
      final userProfile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      if (userProfile['role'] != 'farmer') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only farmers can view this page'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch orders for products created by the logged-in farmer
      final response = await supabase
          .from('orders')
          .select(
          '*, order_items(*, products(name, category)), profiles:consumer_id(name)')
          .eq('order_items.products.farmer_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response as List);
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders Placed", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Text(
          'No orders placed yet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['order_items']);
    final consumer = order['profiles'];
    final createdAt = DateTime.parse(order['created_at']);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order['order_id']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Consumer: ${consumer['name']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...items.map((item) {
              final product = item['products'];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(product['category']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product['category'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${item['quantity']} kg',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 8),
            Text(
              'Total: ₹${order['total'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Delivery: ${order['delivery_info']['address']}, ${order['delivery_info']['city']}, ${order['delivery_info']['zipCode']}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Vegetable':
        return Colors.green[700]!;
      case 'Fruit':
        return Colors.red[400]!;
      case 'Grain':
        return Colors.amber[700]!;
      case 'Herb':
        return Colors.teal[500]!;
      case 'Seed':
        return Colors.brown[400]!;
      case 'Nut':
        return Colors.orange[700]!;
      case 'Pulse':
        return Colors.purple[400]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
