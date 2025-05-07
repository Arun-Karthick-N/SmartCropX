import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'consumer_home_page.dart';
import 'farmer_home_page.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'Consumer';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'name': _nameController.text.trim(),
          'dob': _dobController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (_selectedRole == 'Consumer') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ConsumerHomePage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => FarmerHomePage()));
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),

                  // Role Selection Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.white),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        dropdownColor: Colors.black,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'Consumer',
                            child: Text('Consumer',
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Farmer',
                            child: Text('Farmer',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        underline: SizedBox(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name Field
                  _buildTextField(_nameController, 'Name', TextInputType.text),
                  SizedBox(height: 20),

                  // Date of Birth Field (with Date Picker)
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(_dobController,
                          'Date of Birth (YYYY-MM-DD)', TextInputType.datetime),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Phone Field
                  _buildTextField(
                      _phoneController, 'Phone Number', TextInputType.phone),
                  SizedBox(height: 20),

                  // Email Field
                  _buildTextField(
                      _emailController, 'Email', TextInputType.emailAddress),
                  SizedBox(height: 20),

                  // Password Field
                  _buildTextField(_passwordController, 'New Password',
                      TextInputType.visiblePassword,
                      obscureText: true),
                  SizedBox(height: 20),

                  // Confirm Password Field
                  _buildTextField(_confirmPasswordController,
                      'Confirm Password', TextInputType.visiblePassword,
                      obscureText: true),
                  SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Signup Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up'),
                  ),

                  SizedBox(height: 20),

                  // Back to Login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to Login',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      TextInputType keyboardType,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black.withOpacity(0.5),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          if (hintText.contains('Email') &&
              !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}')
                  .hasMatch(value)) {
            return 'Enter a valid email';
          }
          if (hintText.contains('Password') && value.length < 6)
            return 'Password must be at least 6 characters';
          if (hintText == 'Confirm Password' &&
              value != _passwordController.text)
            return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toString().split(' ')[0];
      });
    }
  }
}
