import 'package:flutter/material.dart';

void showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 16.0),
            _buildSettingsOption(Icons.history, "Order History"),
            _buildSettingsOption(Icons.settings, "General"),
            _buildSettingsOption(Icons.palette, "Theme"),
            _buildSettingsOption(Icons.payment, "Payment History"),
          ],
        ),
      );
    },
  );
}

Widget _buildSettingsOption(IconData icon, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {},
    ),
  );
}
