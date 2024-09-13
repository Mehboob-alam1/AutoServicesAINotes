import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onPressed, required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:14.0),
      child: ElevatedButton(

        onPressed: onPressed,
        child: Text(label.toUpperCase(),),
      ),
    );
  }
}
