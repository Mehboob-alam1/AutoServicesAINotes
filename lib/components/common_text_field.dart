import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key, required this.onChanged, this.keyboardType, required this.label, this.maxLines, required this.hintText, this.controller, this.validator,
  });

  final ValueChanged onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String label;
  final int? maxLines;
  final String hintText;
  final FormFieldValidator? validator;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
            child: Text(label,style: Theme.of(context).textTheme.titleMedium,),
          ),
          TextFormField(
            validator: validator,
            controller: controller,
            maxLines: maxLines,
            onChanged:onChanged,
            keyboardType:keyboardType,
            decoration:  InputDecoration(hintText: hintText),
          ),
        ],
      ),
    );
  }
}
