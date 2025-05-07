import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isAddingToCart = false;
  Map<String, dynamic>? farmerInfo;
  bool isLoadingFarmerInfo = true;

  @override
  void initState() {
    super.initState();
    _loadFarmerInfo();
  }

  Future<void> _loadFarmerInfo() async {
    try {
      setState(() {
        isLoadingFarmerInfo = true;
      });

      final farmerId = widget.product['farmer_id'];
      if (farmerId != null) {
        final response = await supabase
            .from('profiles')
            .select('*')
            .eq('id', farmerId)
            .single();

        setState(() {
          farmerInfo = response as Map<String, dynamic>;
          isLoadingFarmerInfo = false;
        });
      } else {
        setState(() {
          isLoadingFarmerInfo = false;
        });
      }
    } catch (error) {
      print('Error loading farmer info: $error');
      setState(() {
        isLoadingFarmerInfo = false;
      });
    }
  }

  Future<void> _addToCart() async {
    setState(() {
      isAddingToCart = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        _showErrorSnackBar('You must be logged in to add products to cart');
        return;
      }

      // Check if item already exists in cart
      final existingCartItem = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', widget.product['id'])
          .maybeSingle();

      if (existingCartItem != null) {
        // Update quantity if already in cart
        await supabase.from('cart_items').update({
          'quantity': (existingCartItem['quantity'] as int) + quantity,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingCartItem['id']);
      } else {
        // Add new item to cart
        await supabase.from('cart_items').insert({
          'user_id': userId,
          'product_id': widget.product['id'],
          'quantity': quantity,
          'price': widget.product['price'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      _showSuccessSnackBar('Added to cart successfully!');
    } catch (error) {
      _showErrorSnackBar('Failed to add to cart: $error');
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
      case 'Dairy':
        return Colors.blue[300]!;
      case 'Meat':
        return Colors.brown[500]!;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vegetable':
        return Icons.eco;
      case 'Fruit':
        return Icons.apple;
      case 'Grain':
        return Icons.grass;
      case 'Dairy':
        return Icons.breakfast_dining;
      case 'Meat':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image/Icon
            Container(
              height: 200,
              color: _getCategoryColor(widget.product['category']),
              child: Center(
                child: Icon(
                  _getCategoryIcon(widget.product['category']),
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.product['is_organic'] == true)
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Organic',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${widget.product['price']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),

                  // Category
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.product['category'],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Divider(),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  Divider(),

                  // Availability
                  Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'In Stock: ${widget.product['quantity']} kg',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.product['quantity'] > 0
                          ? Colors.green[800]
                          : Colors.red,
                    ),
                  ),

                  Divider(),

                  // Farmer Info
                  Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  isLoadingFarmerInfo
                      ? Center(child: CircularProgressIndicator())
                      : farmerInfo == null
                      ? Text('Seller information not available')
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerInfo!['full_name'] ?? 'Unknown Seller',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (farmerInfo!['location'] != null)
                        Text(
                          'Location: ${farmerInfo!['location']}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1
                            ? () {
                          setState(() {
                            quantity--;
                          });
                        }
                            : null,
                      ),
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: quantity < (widget.product['quantity'] ?? 99)
                            ? () {
                          setState(() {
                            quantity++;
                          });
                        }
                            : null,
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                      isAddingToCart || widget.product['quantity'] <= 0
                          ? null
                          : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff000a00),
                        foregroundColor: Colors.white,
                      ),
                      child: isAddingToCart
                          ? CircularProgressIndicator(color: Colors.white)
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart),
                          SizedBox(width: 8),
                          Text('Add to Cart'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
