import 'package:flutter/material.dart';

const List<DropdownMenuItem<String>> kItems = [
  DropdownMenuItem(
      value: 'Hot', child: Text('Hot: 1-30 days close')),
  DropdownMenuItem(
      value: 'Warm', child: Text('Warm: 30-60 days')),
  DropdownMenuItem(value: 'Cold', child: Text('Cold')),
];