import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_schema.dart';

class IconTextField extends StatelessWidget {
  const IconTextField({
    super.key,
    required this.size, required this.icon, required this.hintText, required this.controller,
  });

  final Size size;
  final IconData icon;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: size.width*0.9,
      child: TextFormField(

        cursorColor: kWhiteColor,
        style: GoogleFonts.quicksand(),

        decoration: InputDecoration(
            prefixIcon:const Icon(Icons.person,color: kWhiteColor,),
            hintText: "Retail Name",
            fillColor: kBlackColor,
            filled: true,
            hintStyle: GoogleFonts.quicksand(),
            border: OutlineInputBorder(

                borderSide: BorderSide.none,

                borderRadius: BorderRadius.circular(8.0)
            )
        ),
      ),
    );
  }
}
