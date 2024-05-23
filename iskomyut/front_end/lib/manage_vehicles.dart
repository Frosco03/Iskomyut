library front_end;

import 'package:db_integration/db_integration.dart';
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
  var db = DBManager();
  bool isReady = false;

  void getVehicles() async{
    vehicles = await db.getValues('vehicles', where: 'companyId = 1', join: 'vehicle_models', joinCondition: 'vehicles.model = vehicle_models.id'); //TODO make sure that the companyID is set to a variable    
    setState((){
      isReady = true;
    });
  }

  /*
    Taken from https://www.flutterclutter.dev/flutter/basics/reload-a-widget-after-navigator-pop/2021/35427/
    method to refresh page every time we do Navigator.pop()
  */
  void _refreshPage(){
    isReady = false;
    setState(() {
      getVehicles();
    });
  }

  @override
  void initState() {
    //Get the list of vehicles available to the company
    getVehicles();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final contextTextTheme = Theme.of(context).textTheme;

    if(!isReady){
      return Container(decoration: const BoxDecoration(color: Colors.white),);
    }

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
              for(var vehicle in vehicles)
                VehicleCard(contextTextTheme: contextTextTheme, model: vehicle['modelName'], plateNo: vehicle['plate'], refreshPage: _refreshPage),
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
              onPressed: () async {
                await Navigator.pushNamed(context, '/add_vehicle_form');
                _refreshPage();
              },
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
    required this.model, 
    required this.plateNo,
    required this.refreshPage,
  });

  final TextTheme contextTextTheme;
  final String model, plateNo;
  final VoidCallback refreshPage;

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
          onTap: () async {
            //Moves to the edit form
            await Navigator.pushNamed(context, '/vehicle_form_update', arguments: {
              'model' : model,
              'plateNo' : plateNo,
            });
            refreshPage();
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
                      Text(model, style: contextTextTheme.titleLarge),
                      Text(plateNo, style: contextTextTheme.titleMedium),
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