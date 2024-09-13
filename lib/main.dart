
import 'package:auto_services_ai_notes/screen/form_view.dart';
import 'package:auto_services_ai_notes/utils/color_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Business Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kBlackColor
        ),
        textTheme: TextTheme(
          titleMedium: GoogleFonts.quicksand(
            color: kWhiteColor,
            fontWeight: FontWeight.w600
          )
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: GoogleFonts.quicksand()
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kBlackColor,
          hintStyle: GoogleFonts.quicksand(),
          labelStyle: GoogleFonts.quicksand(),
          counterStyle: GoogleFonts.quicksand(),
          contentPadding: EdgeInsets.all(20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),)
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w500
          )
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(

          style: ElevatedButton.styleFrom(
            foregroundColor: kWhiteColor,
            backgroundColor: Colors.blue,
            fixedSize: Size(size.width*0.9,49),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 4,
            ),
            textStyle: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500
                ,color: kWhiteColor

            ),
            // textStyle: TextStyle(fontSize: 18),
          ),
        )
      ),
      home: FormView(),
    );
  }
}
