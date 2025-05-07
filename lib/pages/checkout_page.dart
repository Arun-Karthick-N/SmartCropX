import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _deliveryMethod = 'Standard Delivery';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Delivery Information"),
            _buildTextFormField(
              controller: _nameController,
              label: "Full Name",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            _buildTextFormField(
              controller: _phoneController,
              label: "Phone Number",
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            _buildTextFormField(
              controller: _addressController,
              label: "Address",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextFormField(
                    controller: _cityController,
                    label: "City",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildTextFormField(
                    controller: _zipController,
                    label: "Zip Code",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter zip code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildSectionTitle("Delivery Method"),
            _buildDeliveryMethodSelector(),
            SizedBox(height: 24),
            _buildSectionTitle("Order Summary"),
            _buildOrderSummary(),
            SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff000a00),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _proceedToPayment();
                }
              },
              child: Text(
                "Proceed to Payment",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text("Standard Delivery (2-3 days)"),
          subtitle: Text(widget.subtotal > 500 ? "Free" : "₹50.00"),
          value: "Standard Delivery",
          groupValue: _deliveryMethod,
          onChanged: (value) {
            setState(() {
              _deliveryMethod = value!;
            });
          },
          activeColor: Colors.green,
        ),
        RadioListTile<String>(
          title: Text("Express Delivery (1 day)"),
          subtitle: Text(widget.subtotal > 500 ? "Free" : "₹100.00"),
          value: "Express Delivery",
          groupValue: _deliveryMethod,
          onChanged: (value) {
            setState(() {
              _deliveryMethod = value!;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        "${item.quantity}x",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(item.productName),
                      ),
                      Text(
                        "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(height: 24),
            _buildSummaryRow(
                "Subtotal", "₹${widget.subtotal.toStringAsFixed(2)}"),
            SizedBox(height: 4),
            _buildSummaryRow(
              "Delivery Fee",
              widget.subtotal > 500
                  ? "Free"
                  : _deliveryMethod == 'Standard Delivery'
                  ? "₹50.00"
                  : "₹100.00",
            ),
            SizedBox(height: 8),
            _buildSummaryRow(
              "Total",
              "₹${(widget.subtotal + (widget.subtotal > 500 ? 0 : _deliveryMethod == 'Standard Delivery' ? 50.0 : 100.0)).toStringAsFixed(2)}",
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.green[700] : null,
          ),
        ),
      ],
    );
  }

  void _proceedToPayment() {
    final deliveryInfo = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'zipCode': _zipController.text,
      'deliveryMethod': _deliveryMethod,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: widget.cartItems,
          deliveryInfo: deliveryInfo,
          total: widget.subtotal +
              (widget.subtotal > 500
                  ? 0
                  : _deliveryMethod == 'Standard Delivery'
                  ? 50.0
                  : 100.0),
        ),
      ),
    );
  }
}
