import 'package:flutter/material.dart';
import 'prediction_page.dart';
import 'crop_scheduling_page.dart';
import 'ScheduledCropsPage.dart'; // Corrected import with proper case and path
import 'profile_page.dart';
import 'farmer_home_page.dart';

class CropManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Management", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context,
            "Crop Prediction",
            Color(0xff8e0000),
            Colors.white,
            Icons.insights,
                () => _navigateToPrediction(context),
          ),
          _buildDashboardCard(
            context,
            "Crop Scheduling",
            Color(0xff031d93),
            Colors.white,
            Icons.calendar_today,
                () => _navigateToScheduling(context),
          ),
          _buildDashboardCard(
            context,
            "Scheduled Crops",
            Color(0xff065a00),
            Colors.white,
            Icons.list_alt,
                () => _navigateToScheduledCrops(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff000800),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            _navigateToHome(context);
          } else if (index == 1) {
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

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FarmerHomePage()),
    );
  }

  void _navigateToPrediction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PredictionPage()),
    );
  }

  void _navigateToScheduling(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CropSchedulingPage()),
    );
  }

  void _navigateToScheduledCrops(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScheduledCropsPage()),
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
                    _buildSettingsOption(
                        context, Icons.history, "Order History"),
                    _buildSettingsOption(context, Icons.settings, "General"),
                    _buildSettingsOption(context, Icons.palette, "Theme"),
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
          if (title == "Order History") {
            // Implement Order History Navigation
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
