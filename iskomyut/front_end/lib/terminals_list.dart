library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

class TerminalList extends StatefulWidget {
  const TerminalList({super.key});

  @override
  State<TerminalList> createState() => _TerminalListState();
}

class _TerminalListState extends State<TerminalList> {
  var _db = DBManager();
  bool _isReady = false;
  List _terminals = [];

  Future<void> _getTerminals() async{
    //TODO next time get terminals based on user location
    
    _terminals = await _db.getValues('terminals', where: 'terminalCode = "TAC"',);
    setState((){
      _isReady = true;
    });
  }

  @override
  void initState() {
    _getTerminals();
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
          for(var terminal in _terminals)
            TerminalCard(contextTextTheme: contextTextTheme, terminalName: terminal['terminalName'], terminalCode: terminal['terminalCode'],),
        ],
      )
    );
  }
}

class TerminalCard extends StatelessWidget {
  const TerminalCard({
    super.key,
    required this.contextTextTheme,
    required this.terminalName, 
    required this.terminalCode,
  });

  final TextTheme contextTextTheme;
  final String terminalName, terminalCode;

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
            //Moves to the schedule list
            Navigator.pushNamed(context, '/terminal_schedules', arguments: {
              //TODO Fix this
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
                      Text(terminalName, style: contextTextTheme.titleLarge),
                      Text('Terminal Code: $terminalCode', style: contextTextTheme.titleMedium),
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