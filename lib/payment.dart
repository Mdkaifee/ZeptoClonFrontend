import 'package:flutter/material.dart';
import 'addupi.dart';
class PaymentOptionScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  final int totalItems;
  final double grandTotal;

  const PaymentOptionScreen({
    Key? key,
    required this.cartItems,
    required this.totalItems,
    required this.grandTotal,
  }) : super(key: key);

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  String _selectedPaymentMethod = 'upi'; // 'upi' or 'cod'
  String? _selectedUpiApp; // 👈 Move this inside the class

Widget _buildUpiAppIcon(String id, String imageUrl) {
  final bool isSelected = _selectedUpiApp == id;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedUpiApp = id;
        _selectedPaymentMethod = 'upi'; // 👈 Also select UPI radio when icon clicked
      });
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade300 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.network(imageUrl, height: 30),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Options")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review Your Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final product = item['product'];
                  final int quantity = item['quantity'];
                  final double price = (product['price'] as num).toDouble();
                  final double totalPrice = price * quantity;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Product: ${product['name']}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Quantity: ${product['quantity']['value']} ${product['quantity']['unit']}",
                          ),
                          const SizedBox(height: 4),
                          Text("Price per item: ₹${price.toStringAsFixed(2)}"),
                          Text("Total price: ₹${totalPrice.toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5),
            Text("Total items: ${widget.totalItems}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Grand Total: ₹${widget.grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ------------------- Pay by UPI Section -------------------
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pay by UPI",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.payment),
                    title: const Text("Pay by any UPI app"),
                    subtitle: const Text("Use any UPI app on your phone to pay"),
                    trailing: Radio<String>(
                      value: 'upi',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'upi';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUpiAppIcon(
                        'gpay',
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Google_Pay_Logo.svg/512px-Google_Pay_Logo.svg.png?20221017164555',
                      ),
                      _buildUpiAppIcon(
                        'phonepe',
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/PhonePe_Logo.svg/230px-PhonePe_Logo.svg.png?20210407195407',
                      ),
                      _buildUpiAppIcon(
                        'paytm',
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Paytm_Logo_%28standalone%29.svg/60px-Paytm_Logo_%28standalone%29.svg.png?20200830180423',
                      ),
                      _buildUpiAppIcon(
                        'bajaj',
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Bajaj_Finserv_Logo.svg/512px-Bajaj_Finserv_Logo.svg.png?20211130072409',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                 TextButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUpiScreen(
          grandTotal: widget.grandTotal,
          totalItems: widget.totalItems,
        ),
      ),
    );
  },
  icon: const Icon(Icons.add),
  label: const Text(" Add new UPI ID"),
),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------- Cash on Delivery Section -------------------
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text("Cash On Delivery"),
                trailing: Radio<String>(
                  value: 'cod',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'cod';
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // ------------------- Proceed Button -------------------
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _selectedPaymentMethod == 'upi'
                          ? "Proceeding with UPI Payment..."
                          : "Cash on Delivery selected",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Proceed to Pay  ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "₹${widget.grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
