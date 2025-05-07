import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'farmer_home_page.dart';
import 'consumer_home_page.dart';
import 'signup_screen.dart';
import 'forgot_password_page.dart'; // Import ForgotPasswordPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Consumer'; // Default role
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _login() async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', res.user!.id)
            .maybeSingle();

        if (userData != null && userData.isNotEmpty) {
          String userRole = userData['role'];

          if (userRole == _selectedRole) {
            // Navigate to the respective home page
            Widget homePage =
            (userRole == 'Farmer') ? FarmerHomePage() : ConsumerHomePage();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => homePage),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Incorrect role selected!')),
            );
            await supabase.auth.signOut();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User role not found!')),
          );
          await supabase.auth.signOut();
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // Ensure this path is correct
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),

              // Role Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
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

              // Email Field
              _buildTextField(_emailController, 'Enter your email'),
              SizedBox(height: 20),

              // Password Field
              _buildTextField(_passwordController, 'Enter your password',
                  obscureText: true),
              SizedBox(height: 10),

              // Forgot Password
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),

              SizedBox(height: 20),

              // Signup Navigation
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text(
                  'Click here to register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: TextField(
        controller: controller,
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
      ),
    );
  }
}
