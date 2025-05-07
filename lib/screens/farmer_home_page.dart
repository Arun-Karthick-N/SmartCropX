import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_product_page.dart';
import 'manage_products_page.dart';
import 'crop_management_page.dart';
import 'profile_page.dart';
import 'order_placed_page.dart'; // Import OrderPlacedPage

// Get Supabase client instance
final supabase = Supabase.instance.client;

class FarmerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000300),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context,
            "Add New Product",
            Color(0xffda5c03),
            Colors.white,
            Icons.add_circle,
                () => _navigateToAddProduct(context),
          ),
          _buildDashboardCard(
            context,
            "Manage My Products",
            Color(0xfffefefe),
            Color(0xff09008a),
            Icons.list,
                () => _navigateToManageProducts(context),
          ),
          _buildDashboardCard(
            context,
            "Crop Management",
            Color(0xff065a00),
            Colors.white,
            Icons.eco,
                () => _navigateToCropManagement(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff000800),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 1) {
            _navigateToProfile(context);
          } else if (index == 2) {
            _showSettingsBottomSheet(context);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      Color bgColor,
      Color textColor,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          height: 150.0,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40.0, color: textColor),
                SizedBox(height: 8.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );
  }

  void _navigateToManageProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageProductsPage()),
    );
  }

  void _navigateToCropManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CropManagementPage()),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsOption(context, Icons.history, "Orders"),
                    _buildSettingsOption(context, Icons.settings, "General"),
                    _buildSettingsOption(
                        context, Icons.payment, "Payment History"),
                    _buildSettingsOption(context, Icons.logout, "Logout"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption(
      BuildContext context, IconData icon, String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          if (title == "Orders") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPlacedPage()),
            );
          } else if (title == "Logout") {
            _handleLogout(context);
          }
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
