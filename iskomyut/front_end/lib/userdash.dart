library front_end;

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IskomyutAppState(),
      child: const UserHomePage(),
    );
  }
}

class IskomyutAppState extends ChangeNotifier{
}

class UserHomePage extends StatefulWidget{
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late double _lat, _long;

  @override
  void initState() {
    getCurrentLocation().then(
      (value) {
        setState(() {
          _lat = value.latitude;
          _long = value.longitude;
        });
      }      
    );

    super.initState();
  }

  Future<Position> getCurrentLocation() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('Location services denied');
      }

      if(permission == LocationPermission.deniedForever){
        return Future.error('Location services permanently denied. We cannot get your exact location.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

    /*
    * SafeArea is used to prevent the text from being cut due to differing device dimensions
    * The SizedBox which shows the map has an initial zoom level of 9.8 and is set to a
    * predetermined location. We should find a way where we can detect the user's location
    * and set the map to center to the user's location
    */

    return Scaffold(
      body: SafeArea(
        child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16.0),
                    child: Text("Hello, James!", style: contextTextTheme.displaySmall),
                  ),
                ],
              ),

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
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Text("Brgy. 2 Tacloban City", style: contextTextTheme.headlineSmall),
                  ),
                ],
              ),
        
              SizedBox(
                height: 300,
                width: 350,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_lat, _long),
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
        
              const BookButton(),
            ],
          ),
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
        icon: const Icon(
          Icons.directions_car,
          color: Colors.white,
        ),  
        label: Text(
          "Book a ride",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
          ),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),
    );
  }
}