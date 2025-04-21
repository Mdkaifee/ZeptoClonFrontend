// import 'package:flutter/material.dart';
// import 'register_page.dart'; // Ensure you import the RegisterScreen

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToRegister();
//   }

//   void _navigateToRegister() async {
//     await Future.delayed(const Duration(seconds: 5)); // Wait for 2 seconds
//     // ignore: use_build_context_synchronously
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => RegisterPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           'Splash Screen',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'register_page.dart';  // Ensure you import the RegisterScreen
import 'home_screen.dart';  // Import your HomeScreen here
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));  // Wait for 2 seconds

    // Here you would check if the user is logged in
    bool isLoggedIn = await _checkIfLoggedIn();  // Placeholder for login check

    if (isLoggedIn) {
      // Fetch user data or token that you have stored in your preferences or a secure place
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('userToken') ?? '';
      Map<String, dynamic> user = {};  // Retrieve user details as needed

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: token, user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }
  }

  // Future<bool> _checkIfLoggedIn() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // Assuming 'isLoggedIn' is a key you use to store the login state; returns false if not set
  //   return prefs.getBool('isLoggedIn') ?? false;
  // }
Future<bool> _checkIfLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
