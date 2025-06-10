import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/cart.dart';
import 'your_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final Map user;

  const HomeScreen({super.key, required this.token, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _appBarTitle = "Home Screen";
  late Map _user;
  Map<String, int> productQuantities = {}; 
  Map<String, String> cartItems = {}; 
  Map<String, String> productIdToCartItemId = {};
  List<dynamic> products = [];
 List<dynamic> _cartItems = []; // This stores the full cart response from server


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_updateAppBarTitle);
    _user = Map.from(widget.user); // Make a copy to manage locally.
  _appBarTitle = _tabController.index == 0 ? "Hi, ${_user['name']}" : "Account Screen";
  _loadUserData();
  _fetchProducts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_updateAppBarTitle);
    _tabController.dispose();
    super.dispose();
  }
void _loadUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String userDataJson = prefs.getString('userData') ?? '{}';
  Map user = json.decode(userDataJson);

  print("Loaded User Data: $user");

  setState(() {
    _user = user;
    _appBarTitle = _tabController.index == 0
        ? "Hi, ${_user['name'] ?? 'Guest'}"
        : "Account Screen";
  });

  _fetchCartItems(); // ✅ Call this AFTER user is loaded
}

Future<void> _fetchProducts() async {
  var url = Uri.parse('http://192.168.0.129:5000/api/products');
  try {
    var response = await http.get(url);
    print("API Response Status: ${response.statusCode}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      print("Products Data: $responseBody");
      setState(() {
        products = responseBody;
      });
    } else {
      print("Failed to fetch products: ${response.body}");
      Fluttertoast.showToast(
        msg: "Failed to fetch products",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    print("Error fetching products: $e");
    Fluttertoast.showToast(
      msg: "Error fetching products: $e",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
Future<void> _fetchCartItems() async {
  final userId = _user['id'] ?? _user['_id'];

  if (userId == null || userId.toString().isEmpty) {
    print("User ID is null or empty. Cannot fetch cart.");
    return;
  }

  final url = Uri.parse('http://192.168.0.129:5000/api/cart/user/$userId');
  print("Fetching cart for user: $userId");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> cartData = json.decode(response.body);

      // ✅ CLEAR OLD STATE before reassigning
      setState(() {
        _cartItems = cartData;
        productQuantities.clear(); // ✅ This fixes stale `productQuantities`
        productIdToCartItemId.clear();

        for (var item in cartData) {
          final String productId = item['product']['_id'];
          final int quantity = item['quantity'];
          final String cartItemId = item['_id'];

          productQuantities[productId] = quantity;
          productIdToCartItemId[productId] = cartItemId;
        }
      });

      print("Cart loaded successfully: $cartData");

      // Debugging summary (optional)
      double grandTotal = 0.0;
      int totalItems = 0;
      for (var item in cartData) {
        final product = item['product'];
        final int quantityInCart = item['quantity'];
        final double price = (product['price'] as num).toDouble();
        final double totalPrice = price * quantityInCart;

        final name = product['name'];
        final quantityValue = product['quantity']['value'].toString();
        final quantityUnit = product['quantity']['unit'];
        final imageUrl = product['image'];

        print("\nProduct: $name");
        print(" - Quantity: $quantityValue $quantityUnit");
        print(" - Image URL: $imageUrl");
        print(" - Price per item: \$${price.toStringAsFixed(2)}");
        print(" - Quantity in cart: $quantityInCart");
        print(" - Total price: \$${totalPrice.toStringAsFixed(2)}");

        grandTotal += totalPrice;
        totalItems += quantityInCart;
      }

      print("\nTotal items in cart: $totalItems");
      print("Grand total price: \$${grandTotal.toStringAsFixed(2)}");
      print("----------------------\n");
    } else {
      print("Failed to load cart items: ${response.body}");
    }
  } catch (e) {
    print("Error fetching cart items: $e");
  }
}

   Future<void> _logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');  // Remove login state
    await prefs.remove('userToken');   // Remove user token
    await prefs.remove('userData');    // Remove user data (if stored)
  }
void _updateAppBarTitle() {
  if (!_tabController.indexIsChanging) {
    setState(() {
      _appBarTitle = _tabController.index == 0 ? "Hi, ${_user['name'] ?? 'Guest'}" : "Account Screen";
    });
  }
}

  void updateUser(Map updatedUser) {
    setState(() {
      _user = updatedUser; // Update the local user with new data.
    });
  }
bool isAddingToCart = false;

void addToCart(String userId, String productId, int quantity) async {
  if (isAddingToCart) {
    print("Request is already in progress.");
    return;
  }

  try {
    isAddingToCart = true;
    var url = Uri.parse('http://192.168.0.129:5000/api/cart/add');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = jsonDecode(response.body);
      if ((responseBody['message'] == 'Item quantity updated in cart' || 
           responseBody['message'] == 'Item added to cart') && responseBody['cartItemId'] != null) {

        // Store the cartItemId immediately after adding/updating
        storeCartItemId(productId, responseBody['cartItemId']);

        print("Success: ${responseBody['message']}, Cart Item ID: ${responseBody['cartItemId']}");
      await _fetchCartItems();
      } else {
        print("Failed to store Cart Item ID. Response: ${responseBody['message']}");
      }
    } else {
      print('Failed to add item to cart, Response: ${response.body}');
    }
  } finally {
    isAddingToCart = false;
  }
}
Future<void> updateCart(String cartItemId, int quantityChange, int fallbackQuantity, String productId) async {
  print("Attempting to update cart with ID: $cartItemId");  // Log the ID being sent

  var url = Uri.parse('http://localhost:5000/api/cart/update');
  var response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'cartItemId': cartItemId,
      'quantityChange': quantityChange,
    }),
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    print("Update successful: $responseBody");

    // Handle item removal case
    if (responseBody['message'] == "Item removed from cart") {
      setState(() {
        productQuantities.remove(productId);
        productIdToCartItemId.remove(productId);
      });
    }
    await _fetchCartItems();
  } else {
    print("Failed to update cart: ${response.body}");
    setState(() {
      productQuantities[productId] = fallbackQuantity;
    });
  }
}

void incrementQuantity(String productId) {
  setState(() {
    productQuantities[productId] = (productQuantities[productId] ?? 0) + 1;
  });
  if (_user != null && _user['id'] != null) {
    addToCart(_user['id'], productId, 1);
  }
}
void storeCartItemId(String productId, String cartItemId) {
  productIdToCartItemId[productId] = cartItemId;
}
// Future<void> decrementQuantity(String productId, String cartItemId) async {
//   int currentQuantity = productQuantities[productId] ?? 0;

//   if (currentQuantity > 0) {
//     int newQuantity = currentQuantity - 1;

//     // 👇 Only update state temporarily
//     if (newQuantity == 0) {
//       setState(() {
//         productQuantities.remove(productId);  // ❗ REMOVE key entirely
//         productIdToCartItemId.remove(productId);
//       });
//     } else {
//       setState(() {
//         productQuantities[productId] = newQuantity;
//       });
//     }

//     print("Decrementing quantity for Cart Item ID: $cartItemId");

//     await updateCart(cartItemId, -1, currentQuantity, productId);
//   } else {
//     print("Quantity already at zero, cannot decrement further.");
//   }
// }
Future<void> decrementQuantity(String productId, String cartItemId) async {
  int currentQuantity = productQuantities[productId] ?? 0;

  if (currentQuantity > 0) {
    int newQuantity = currentQuantity - 1;

    // Log before updating
    print("Attempting to decrement cart item: $cartItemId");
    print("Current Quantity: $currentQuantity, New Quantity: $newQuantity");

    // Remove the item if quantity is zero
    if (newQuantity == 0) {
      print("Item quantity is zero. Proceeding to remove from cart.");

      setState(() {
        productQuantities.remove(productId);  // Remove the key for the product
        productIdToCartItemId.remove(productId);
      });

      // Call API to remove the item from the cart in the backend
      var url = Uri.parse('http://192.168.0.129:5000/api/cart/remove/$cartItemId'); // Ensure the URL is correct
      var response = await http.delete(url); // Use DELETE method if you're deleting the cart item

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Item removed from cart successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // Reload the cart after deletion
        await _fetchCartItems();
      } else {
        Fluttertoast.showToast(
          msg: "Failed to remove item from cart",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      setState(() {
        productQuantities[productId] = newQuantity;  // Decrement quantity in UI
      });

      // Call API to update the cart quantity
      await updateCart(cartItemId, -1, currentQuantity, productId);
    }
  } else {
    print("Quantity already at zero, cannot decrement further.");
  }
}

int _getTotalItems() {
  int total = 0;
  for (var item in _cartItems) {
    total += item['quantity'] as int;
  }
  return total;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
actions: [
  Stack(
    children: [
      IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () async {
          await _fetchCartItems();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(cartItems: _cartItems,onCartChanged: _fetchCartItems,),
            ),
          );

          await _fetchCartItems();
           setState(() {});
        },
      ),
      if (_cartItems.isNotEmpty)
        Positioned(
          right: 6,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Text(
              _getTotalItems().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
    ],
  )
],

        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "Home"), Tab(text: "Account")],
        ),
      ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Home tab content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("Name: ${_user['name']}"),
              // Text("Email: ${_user['email']}"),
              // Text("Mobile: ${_user['mobile']}"),
              Text("userId: ${_user['id']}"),
              Expanded(
    child: GridView.builder(
  padding: const EdgeInsets.all(10),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.8,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    String productId = products[index]['_id'];
    int currentQuantity = productQuantities[productId] ?? 0;
    return Card(
  elevation: 5,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.network(
        products[index]['image'],
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(products[index]['name']),
            Text('₹${products[index]['price']}'),

            // ✅ RE-COMPUTE `currentQuantity` RIGHT BEFORE DISPLAY
            Builder(
              builder: (context) {
                int currentQuantity = productQuantities[productId] ?? 0;

                return currentQuantity > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              String cartItemId =
                                  productIdToCartItemId[productId] ?? '';
                              if (cartItemId.isNotEmpty) {
                                decrementQuantity(productId, cartItemId);
                              }
                            },
                          ),
                          Text('$currentQuantity'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => incrementQuantity(productId),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _user['id'] != null
                            ? () {
                                incrementQuantity(productId);
                                int quantity =
                                    productQuantities[productId] ?? 0;
                                addToCart(
                                    _user['id'], productId, quantity);
                              }
                            : null,
                        child: Text('Add to Cart'),
                      );
              },
            )
          ],
        ),
      )
    ],
  ),
);

  },

    ))
           ],
          ),
        ),
          // Account tab content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text("Edit Profile"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProfileScreen(
                              user: _user,
                              updateUser: updateUser,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
  icon: Icon(Icons.list),
  label: Text("View Orders"),
  onPressed: () {
    // Navigate to YourOrdersScreen, no need to pass orders data anymore
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const YourOrdersScreen(),  // No need to pass data
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.green,
  ),
),


                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("No"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await _logoutUser();
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/loginPage', // You might need to navigate to the splash screen or login page directly
                                (Route<dynamic> route) => false,
                              );
                              Fluttertoast.showToast(
                                msg: "User logged out successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                            child: Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  final Map user;
  final Function(Map) updateUser;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.updateUser,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(
      text: user['name'] ?? '',
    );
    TextEditingController mobileController = TextEditingController(
      text: user['mobile'] ?? '',
    );

    String userId = user['_id'] ?? user['id'] ?? '';

Future<void> updateProfile() async {
  if (nameController.text.isEmpty) {
    Fluttertoast.showToast(
      msg: "Name cannot be empty",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  // Validate mobile number length
  if (mobileController.text.length != 10) {
    Fluttertoast.showToast(
      msg: "Enter a valid 10-digit mobile number",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  if (userId.isEmpty) {
    Fluttertoast.showToast(
      msg: "Invalid user ID format",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  var url = Uri.parse('http://192.168.0.129:5000/api/user/edit/$userId');
  try {
    var response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'mobile': mobileController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Update the user on the HomeScreen with the new data
      updateUser({
        ...user,
        'name': nameController.text,
        'mobile': mobileController.text,
      });

      // Save the updated user data to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode({
        'name': nameController.text,
        'email': user['email'], // Retain other user data
        'mobile': mobileController.text,
        'id': userId,
      }));

      Fluttertoast.showToast(
        msg: "Profile updated successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop(); // Go back to the previous screen
    } else {
      Fluttertoast.showToast(
        msg: "Failed to update profile: ${json.decode(response.body)['message']}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error updating profile: $e",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}


    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(labelText: "Mobile"),
              keyboardType:
                  TextInputType
                      .number, // Ensures the keyboard is suitable for numbers
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ], // Allow digits only
            ),
            SizedBox(height: 20),
            // Text('User ID: $userId'),
            // SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}