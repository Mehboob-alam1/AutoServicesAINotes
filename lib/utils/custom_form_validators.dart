import 'package:flutter/cupertino.dart';
//TODO VALIDATIONS ARE HERE
class CFValidators {
  static String? phoneNum(value) {
  if (value == null || value.isEmpty) {
  return 'Phone number is required';
  }
  return null;
  }
  static String? retailName(value) {
  if (value == null || value.isEmpty) {
  return 'Retail name is required';
  }
  return null;
  }
  static String? visitSummary(value) {
    if (value == null || value.isEmpty) {
      return 'Visit Summ. is required';
    }
    return null;
  }

  static String? nextAction(value) {
    if (value == null || value.isEmpty) {
      return 'Next Action is Required';
    }
    return null;
  }
}
