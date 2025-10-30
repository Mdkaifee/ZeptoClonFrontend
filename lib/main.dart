import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'account_screen.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const SplashScreen(),
        '/loginPage': (context) => LoginPage(),
        '/registerPage': (context) => const RegisterPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add this line
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Add this line
      setState(() {
        _isLoading = true;
      });
      var url = Uri.parse('https://5e0c1fb67d19.ngrok-free.app/api/auth/login');
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );
if (response.statusCode == 200) {
  var data = json.decode(response.body);
  var user = data['user']; // Ensure this key actually exists in response
  
  // Check if user contains 'userId'
  if (user != null && user['id'] != null) {
    print('User ID: ${user['id']}'); // Debugging log to see if the userId is present

    // Save login state, token, and user data to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user['id']);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userToken', data['token']);
    await prefs.setString('userData', json.encode(user)); // Storing user data as JSON string

    // Log the saved userId
    String? savedUserId = prefs.getString('userId');
    print('Saved User ID: $savedUserId'); // Log to check if the userId is saved correctly

    Fluttertoast.showToast(
      msg: "Login Successful!",
      backgroundColor: Colors.green,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(token: data['token'], user: user),
      ),
    );
  } else {
    print("User ID is missing in the response!");
    Fluttertoast.showToast(
      msg: "Failed to login: User ID is missing.",
      backgroundColor: Colors.red,
    );
  }
}


else {
  Fluttertoast.showToast(
    msg: "Failed to login: ${response.body}",
    backgroundColor: Colors.red,
  );
}

      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Use the global key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  // Validator for email
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  // Validator for password
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registerPage');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}