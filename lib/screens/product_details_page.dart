import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({Key? key, required this.productId})
      : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic>? productData;
  Map<String, dynamic>? farmerData;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });

    print(
        "🔍 Fetching details for product ID: ${widget.productId}"); // Debugging

    try {
      // Fetch product details
      final productResponse = await supabase
          .from('products')
          .select('*')
          .eq('id', widget.productId)
          .maybeSingle(); // Use maybeSingle to avoid crashes

      print("✅ Product Response: $productResponse"); // Debugging

      if (productResponse == null) {
        throw Exception("Product not found in database.");
      }

      final farmerId = productResponse['farmer_id'];

      // Fetch farmer details
      final farmerResponse = await supabase
          .from('profiles')
          .select('full_name, phone_number, location')
          .eq('id', farmerId)
          .maybeSingle();

      print("✅ Farmer Response: $farmerResponse"); // Debugging

      setState(() {
        productData = productResponse;
        farmerData = farmerResponse;
      });
    } catch (error) {
      print('❌ Error fetching product details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading product details'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading
              ? "Product Details"
              : productData?['name'] ?? "Product Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : productData == null
          ? Center(child: Text("🚫 Product not found"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),

            // Product Name
            Text(
              productData!['name'],
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Price and Organic Badge
            Row(
              children: [
                Text(
                  "₹${productData!['price'].toString()}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff000a00)),
                ),
                Text(" per kg",
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade700)),
                Spacer(),
                if (productData!['is_organic'] == true)
                  _buildOrganicBadge(),
              ],
            ),
            SizedBox(height: 16),

            // Category and Quantity
            Row(
              children: [
                _buildInfoChip(Icons.category,
                    'Category: ${productData!['category']}'),
                SizedBox(width: 10),
                _buildInfoChip(Icons.inventory_2,
                    'Available: ${productData!['quantity']} kg'),
              ],
            ),
            SizedBox(height: 24),

            // Description
            _buildSectionTitle("Description"),
            Text(
              productData!['description'] ??
                  "No description available",
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade800),
            ),
            SizedBox(height: 24),

            // Farmer Information
            if (farmerData != null) ...[
              _buildSectionTitle("Farmer Information"),
              SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xff000a00),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(farmerData!['full_name'] ?? "Unknown"),
                subtitle: Text(farmerData!['location'] ??
                    "Location not specified"),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xff000a00)),
                title: Text(farmerData!['phone_number'] ??
                    "No phone number provided"),
              ),
            ],
            SizedBox(height: 40),

            // Contact Button
            ElevatedButton(
              onPressed: () {
                // Implementation for contacting the farmer
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat),
                    SizedBox(width: 8),
                    Text('Contact Farmer',
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff000a00),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganicBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text('Organic',
              style: TextStyle(
                  color: Colors.green.shade800, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
