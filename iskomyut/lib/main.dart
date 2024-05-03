import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IskomyutAppState(),
      child: MaterialApp(
        title: 'Iskomyut',
        theme: ThemeData(
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
            fontStyle:
            //TODO: Set txt theme as WORK SANS for text
            )
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00FF00)),
        ),
        home: UserHomePage(),
      ),
    );
  }
}

class IskomyutAppState extends ChangeNotifier{

}

class UserHomePage extends StatelessWidget{
  final headerStyle = TextStyle();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, name", style: headerStyle),
        
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text("Book a ride"),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
  
}