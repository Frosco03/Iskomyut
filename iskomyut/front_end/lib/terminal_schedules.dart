library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

class TerminalSchedules extends StatefulWidget {
  const TerminalSchedules({super.key});

  @override
  State<TerminalSchedules> createState() => _TerminalSchedulesState();
}

class _TerminalSchedulesState extends State<TerminalSchedules> {
  final _db = DBManager();
  bool _isReady = false;
  List schedules = [];

  Future<void> _getSchedules() async{
    //TODO next time get terminals based on user location
    List<String> _joins = [
      'INNER JOIN schedules ON routes.id = schedules.routeId',
      'INNER JOIN service_providers ON routes.serviceProvider = service_providers.id',
      'INNER JOIN terminals AS destTerminal ON routes.destination=destTerminal.id'
    ];

    List<String> _cols = [
      'routes.id',
      'routes.price',
      'destTerminal.terminalCode AS destCode',
      'destTerminal.terminalName AS destName',
      'schedules.date',
      'service_providers.companyName'
    ];

    schedules = await _db.getValues('routes', where: 'origin = 1', joins: _joins, columns: _cols);
    setState((){
      _isReady = true;
    });
  }

  @override
  void initState() {
    _getSchedules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

    if(!_isReady){
      return Container(decoration: const BoxDecoration(color: Colors.white),);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terminals Near You"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView(
        children: [
          for(var schedule in schedules)
            ScheduleCard(contextTextTheme: contextTextTheme, destination: schedule['destName'], destinationCode: schedule['destCode'], price: schedule['price'].toString(), serviceProvider: schedule['companyName'], date: schedule['date'], ),
        ],
      )
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.contextTextTheme,
    required this.destination, 
    required this.destinationCode,
    required this.price,
    required this.serviceProvider,
    required this.date,
  });

  final TextTheme contextTextTheme;
  final String destination, destinationCode, price, serviceProvider, date;

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
          onTap: (){
            //Moves to the edit form
            Navigator.pushNamed(context, '/vehicle_form_update', arguments: {
              'model' : Placeholder,
              'plateNo' : Placeholder,
            });
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
                      image: AssetImage('assets/terminalico.png'),
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
                      Text('$destination ($destinationCode)', style: contextTextTheme.titleLarge),
                      Text('$price | $serviceProvider', style: contextTextTheme.titleMedium),
                      Text(date, style: contextTextTheme.titleMedium),
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