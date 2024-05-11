import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Iskomyut/front_end/lib/userdash.dart';
import 'package:Iskomyut/front_end/lib/login.dart';
import 'package:Iskomyut/front_end/lib/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00FF00), background: Colors.white),
          textTheme: Theme.of(context).textTheme.copyWith(
            displaySmall: GoogleFonts.workSans().copyWith(
              fontWeight: FontWeight.w600,
            ),
            headlineLarge: GoogleFonts.workSans().copyWith(
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: GoogleFonts.workSans(),
            titleMedium: GoogleFonts.workSans(),
            labelLarge: GoogleFonts.workSans(),
          ).apply(
            bodyColor: Color(0xFF393939),
            displayColor: Color(0xFF393939),
          ),  
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF48B29)),
            ),
          ),
        ),
        initialRoute: '/login',
        routes:{
          '/': (context) => Loading(),
          '/dash': (context) => UserDashboard(),
          '/login': (context) => Login(),
        }
      );
  }
}

