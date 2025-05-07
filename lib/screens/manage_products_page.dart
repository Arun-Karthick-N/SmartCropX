import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_details_page.dart';
import 'add_product_page.dart';

// Get Supabase client instance
final supabase = Supabase.instance.client;

class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFarmerProducts();
  }

  Future<void> _fetchFarmerProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final response = await supabase
          .from('products')
          .select('*')
          .eq('farmer_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Error fetching products: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToProductDetails(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Manage My Products", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFarmerProducts,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : products.isEmpty
            ? Center(
          child: Text(
            "No products added yet!",
            style:
            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin:
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _navigateToProductDetails(product['id']),
                child: ListTile(
                  leading:
                  Icon(Icons.shopping_bag, color: Colors.green),
                  title: Text(product['name']),
                  subtitle: Text(
                      "Price: ₹${product['price']} | Quantity: ${product['quantity']} kg"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _navigateToEditProduct(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            product['id'], product['name']),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Color(0xff000a00),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );

    if (result == true) {
      _fetchFarmerProducts(); // Refresh list if product was added
    }
  }

  void _navigateToEditProduct(Map<String, dynamic> product) async {
    // This would navigate to an edit product page
    // For now, just print the product details
    print('Edit product: ${product['name']}');
  }

  Future<void> _confirmDelete(String productId, String productName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete "$productName"?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(productId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
      _fetchFarmerProducts(); // Refresh the product list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Product deleted successfully!"),
            backgroundColor: Colors.red),
      );
    } catch (error) {
      print('Error deleting product: $error');
    }
  }
}
