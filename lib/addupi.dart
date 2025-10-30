import 'package:flutter/material.dart';

class AddUpiScreen extends StatelessWidget {
  final int totalItems;
  final double grandTotal;

  const AddUpiScreen({
    super.key,
    required this.totalItems,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController upiController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Add new UPI ID")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("UPI ID / VPA"),
            const SizedBox(height: 8),
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                hintText: "e.g rakesh@upi",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "A collect request will be sent to this UPI ID",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
               onPressed: () {
  final upiId = upiController.text.trim();

  if (upiId.isEmpty) {
    // Show error if UPI ID is empty
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid UPI ID")),
    );
    return;
  }

  // Show success if it's not empty
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Request sent to $upiId")),
  );
},

                child: const Text("Verify and Pay"),
              ),
            ),
            const SizedBox(height: 16),
            Text("Items: $totalItems | Total: ₹${grandTotal.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
