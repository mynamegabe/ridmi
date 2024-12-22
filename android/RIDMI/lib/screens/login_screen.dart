import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous errors
    });

    try {
      print(Uri.parse('${Config.apiBaseUrl}/auth/login'));
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/login'),
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the login response
        final data = jsonDecode(response.body);

        // Save the access_token in SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token']);
        print('Access token saved: ${data['access_token']}');

        // Fetch user data from /users/me
        final userResponse = await http.get(
          Uri.parse('${Config.apiBaseUrl}/users/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${data['access_token']}',
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);

          // Save user data globally
          Provider.of<UserProvider>(context, listen: false).setUserData(userData);

          print('User data fetched and saved globally: $userData');

          // Redirect to /home
          Navigator.pushNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = 'Failed to fetch user data';
          });
        }
      } else {
        // Handle login error (e.g., incorrect credentials)
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      // Handle network errors or other exceptions
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        print('Error: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Full-Screen Background with Offset
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0, // Fill until the bottom
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/globe_1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Foreground Content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // Language Dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: DropdownButton<String>(
                            value: 'English',
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {},
                            items: <String>['English', 'Spanish', 'French']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Logo
                      Image.asset(
                        'assets/images/ridmi_logo.png',
                        width: 150,
                      ),
                      const SizedBox(height: 100),

                      // Email Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: 'Email',
                            border: const OutlineInputBorder(),
                            errorText: _errorMessage,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,  // This makes the text input hidden (password style)
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Continue Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _login,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('or'),
                      const SizedBox(height: 20),

                      // Continue with SSO
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Continue with SSO',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Continue with Company Email',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
