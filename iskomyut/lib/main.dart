import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00FF00), background: Colors.white),
          textTheme: Theme.of(context).textTheme.copyWith(
            headlineLarge: GoogleFonts.workSans().copyWith(
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: GoogleFonts.workSans(),
            titleMedium: GoogleFonts.workSans(),
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
        home: UserHomePage(),
      ),
    );
  }
}

class IskomyutAppState extends ChangeNotifier{

}

class UserHomePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello, James!",
          style: contextTextTheme.headlineLarge,
          ),
        backgroundColor: Colors.white,
      ),
      body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16.0, bottom: 2.0),
                  child: Text("You are currently in", style: contextTextTheme.titleMedium),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 2.0),
                  child: Text("Brgy. 2 Tacloban City", style: contextTextTheme.headlineSmall),
                ),
              ],
            ),

            SizedBox(
              height: 300,
              width: 350,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(51.509364, -0.128928),
                  initialZoom: 9.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                ],
              )
            ),

            BookButton(),
          ],
        ),
    );
  }
  
}

class BookButton extends StatelessWidget {
  const BookButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.directions_car,
          color: Colors.white,
        ),  
        label: Text(
          "Book a ride",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
          ),
        onPressed: () {},
      ),
    );
  }
}