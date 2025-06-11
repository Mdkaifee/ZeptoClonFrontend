import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'home_screen.dart'; // Import HomeScreen

class YourOrdersScreen extends StatefulWidget {
  final bool isFromPayWithCash;

  const YourOrdersScreen({Key? key, this.isFromPayWithCash = false}) : super(key: key);

  @override
  _YourOrdersScreenState createState() => _YourOrdersScreenState();
}

class _YourOrdersScreenState extends State<YourOrdersScreen> {
  late Future<List<dynamic>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _fetchOrders();  // Fetch the orders
  }

  Future<List<dynamic>> _fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // Fetch userId from SharedPreferences

    if (userId == null || userId.isEmpty) {
      Fluttertoast.showToast(
        msg: "User not logged in",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return []; // Return empty list if user is not logged in
    }

    final url = Uri.parse('http://192.168.0.129:5000/api/orders/user/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Sort orders by createdAt in descending order (most recent first)
        data.sort((a, b) {
          DateTime dateA = DateTime.parse(a['createdAt']);
          DateTime dateB = DateTime.parse(b['createdAt']);
          return dateB.compareTo(dateA); // Descending order
        });

        return data;
      } else {
        Fluttertoast.showToast(
          msg: "Failed to fetch orders",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching orders: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return [];
    }
  }
@override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
  if (widget.isFromPayWithCash) {
    // If coming from PayWithCashScreen, navigate to HomeScreen with required parameters
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      final user = json.decode(userData);
      final token = prefs.getString('userToken') ?? ''; // Assuming you have the token in shared preferences

      // Use pushAndRemoveUntil to replace the screen and clear the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            token: token,  // Pass the token
            user: user,    // Pass the user
          ),
        ),
        (Route<dynamic> route) => false, // Removes all previous routes
      );
    }
    return false;  // Prevent the default back navigation
  }
  return true;  // Default behavior for back button
},

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _orders, // The data to fetch
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            } else {
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final orderDate = DateTime.parse(order['createdAt']);
                  final localDate = orderDate.toLocal();
                  final formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(localDate);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: ${order['_id']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          for (var item in order['cartItems'])
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Product: ${item['product']['name']}"),
                                Text("Quantity: ${item['quantity']}"),
                                const SizedBox(height: 5),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Text("Total Items: ${order['cartItems'].length}"),
                          Text("Total Amount: ₹${order['totalAmount']}"),
                          Text("Payment Status: ${order['paymentStatus']}"),
                          Text("Order Status: ${order['orderStatus']}"),
                          Text("Date and Time: $formattedDate"),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }}
