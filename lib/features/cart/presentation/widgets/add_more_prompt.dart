import 'package:flutter/material.dart';

class AddMorePrompt extends StatelessWidget {
  const AddMorePrompt({
    required this.onAddMore,
    super.key,
  });

  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Missed something?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        TextButton(
          onPressed: onAddMore,
          child: const Text('Add More'),
        ),
      ],
    );
  }
}
