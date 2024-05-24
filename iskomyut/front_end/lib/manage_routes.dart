library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

class ManageRoutes extends StatefulWidget {
  const ManageRoutes({super.key});

  @override
  State<ManageRoutes> createState() => _ManageRoutesState();
}

class _ManageRoutesState extends State<ManageRoutes> {
  List routes = [];
  var db = DBManager();
  bool isReady = false;

  void getRoutes() async{
    List<String> join = [
      'INNER JOIN terminals AS origTerminal ON routes.origin=origTerminal.id',
      'INNER JOIN terminals AS destTerminal ON routes.destination=destTerminal.id'
    ];

    List<String> cols = [
      'origTerminal.terminalCode AS origCode',
      'origTerminal.terminalName AS oTerminalName',
      'destTerminal.terminalName AS dTerminalName', 
      'destTerminal.terminalCode AS destCode',
      'routes.price',
      'routes.id',
    ];

    routes = await db.getValues('routes', columns: cols, where: 'serviceProvider = 1', joins: join); //TODO make sure that the companyID is set to a variable    
    print(routes);
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
      getRoutes();
    });
  }

  @override
  void initState() {
    //Get the list of routes that the company provides
    getRoutes();
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
        title: const Text("Manage Routes"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            children: [
              for(var route in routes)
                RouteCard(contextTextTheme: contextTextTheme, originCode: route['origCode'], destinationCode:route['destCode'], originTerminal: route['oTerminalName'], destinationTerminal: route['dTerminalName'], refreshPage: _refreshPage, price: route['price'].toString(), routeID: route['id'].toString(),),
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
                await Navigator.pushNamed(context, '/add_route_form');
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

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.contextTextTheme,
    required this.originCode, 
    required this.destinationCode,
    required this.originTerminal,
    required this.destinationTerminal,
    required this.refreshPage,
    required this.price,
    required this.routeID,
  });

  final TextTheme contextTextTheme;
  final String originCode, destinationCode, originTerminal, destinationTerminal, price, routeID;
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
            await Navigator.pushNamed(context, '/update_route_form', arguments: {
              'originCode' : originCode,
              'destinationCode' : destinationCode,
              'price' : price,
              'routeID' : routeID,
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
                      image: AssetImage('assets/routeico.png'),
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
                      Text('$originCode - $destinationCode', style: contextTextTheme.titleLarge),
                      Text('$originTerminal-$destinationTerminal', style: contextTextTheme.titleMedium),
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