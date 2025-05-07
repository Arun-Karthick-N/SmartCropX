import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You must be logged in to view order history'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Check if the user is a consumer
      final userProfile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      if (userProfile['role'] != 'consumer') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only consumers can view this page'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch orders for the logged-in consumer
      final response = await supabase
          .from('orders')
          .select(
          '*, order_items(*, products(name, category, price)), profiles:consumer_id(name)')
          .eq('consumer_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response as List);
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order history: $error'),
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
        title: Text("Order History", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff004c00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Text(
          'No orders found',
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
    final createdAt = DateTime.parse(order['created_at']);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    final items = List<Map<String, dynamic>>.from(order['order_items']);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Row(
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Total: ₹${order['total'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...items.map((item) => _buildOrderItem(item)).toList(),
                SizedBox(height: 8),
                Text(
                  'Delivery: ${order['delivery_info']['address']}, ${order['delivery_info']['city']}, ${order['delivery_info']['zipCode']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                SizedBox(height: 4),
                Text(
                  'Recipient: ${order['delivery_info']['name']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final product = item['products'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: ${item['quantity']} kg',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Price: ₹${product['price'].toStringAsFixed(2)}/kg',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '₹${(item['quantity'] * product['price']).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
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
