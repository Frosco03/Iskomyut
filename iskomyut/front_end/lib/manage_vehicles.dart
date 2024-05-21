library front_end;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ManageVehicles extends StatefulWidget {
  const ManageVehicles({super.key});

  @override
  State<ManageVehicles> createState() => _ManageVehiclesState();
}

class _ManageVehiclesState extends State<ManageVehicles> {
  List vehicles = [];

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Vehicles"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            children: [
              VehicleCard(contextTextTheme: contextTextTheme),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFF48B29),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
                side: const BorderSide(
                  color: Color(0xFFF48B29),
                  width: 2,
                ),
              ),
              onPressed: () {},
              child: const Text('+'),
            ),
          ),
        ]
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.contextTextTheme,
  });

  final TextTheme contextTextTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 0,
            blurRadius: 20,
          )
        ]
      ),
      child: Card(
        color: const Color(0xFFF4F4F4),
        child: InkWell(
          onTap: () {
            //TODO go to the edit form
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.25,
                      maxHeight: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: const Image(
                      image: AssetImage('assets/vanico.png'),
                    )
                  ),
                ]
              ),
              Expanded( 
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Toyota Hiace', style: contextTextTheme.titleLarge),
                      Text('AKA4206', style: contextTextTheme.titleMedium),
                    ]
                  ),
                ),
              ),
            ]
          ),
        )
      ),
    );
  }
}