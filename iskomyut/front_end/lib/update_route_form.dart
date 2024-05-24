library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class UpdateRouteForm extends StatefulWidget {
  const UpdateRouteForm({super.key});

  @override
  State<UpdateRouteForm> createState() => _UpdateRouteFormState();
}

class _UpdateRouteFormState extends State<UpdateRouteForm> {
  Map _data = {};
  bool _isReady = false;
  List<DropdownMenuItem<String>> _dropdownItems = [];
  final _db = DBManager();
  final List<String> _days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  List<bool> _dayValues = [false, false, false, false, false, false, false];
  String _originValue = "", _destValue = "";
  final TextEditingController _controller = new TextEditingController();
  bool _firstInit = true;
  List _terminals = [];

  @override
  void initState() {
    super.initState();
    getTerminals().then((response) {
      setState(() {
        print(response);
        _terminals = response;
        _dropdownItems = List.generate(
          response.length,
          (index) => DropdownMenuItem(
            value: response[index]['id'].toString(),
            child: Text('${response[index]['terminalCode']} (${response[index]['terminalName']})')
          )
        );
      });

      _isReady = true;
    });
  }

  Future<List> getTerminals() async{
    List terminals = await _db.getValues('terminals');
    return terminals;
  }

  void changeDropdownSelection(String value, int id){
    setState((){
      if(id == 1){
        _originValue = value;
      }
      else{
        _destValue = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;
    _data = ModalRoute.of(context)!.settings.arguments as Map;

    if(!_isReady){
      return Container(decoration: const BoxDecoration(color: Colors.white),);
    }

    //Only set the value of the forms when the page is initialized for the first time
    if(_firstInit){
      _controller.text = _data['price'];

      //Get the row from the list of maps response from the SQL call by iterating through the terminals list
      _terminals.forEach((element){
        if(element['terminalCode'] == _data['originCode']){
          _originValue = element['id'].toString();
        }
        if(element['terminalCode'] == _data['destinationCode']){
          _destValue = element['id'].toString();
        }
      });
    }
    _firstInit = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Existing Route"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width*.10),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                physics: const RangeMaintainingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: DropdownFormInput(
                            contextTextTheme: contextTextTheme, 
                              labelText: "Origin", 
                              items: _dropdownItems,
                              icon: Icons.pin_drop,
                              validator: (value) => value==null ? 'Please select a location.' : null,
                              id: 1,
                              selectedValue: _originValue,
                              onChange: changeDropdownSelection,
                          )
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: DropdownFormInput(
                            contextTextTheme: contextTextTheme, 
                              labelText: "Destination", 
                              items: _dropdownItems,
                              icon: Icons.pin_drop,
                              validator: (value) => value==null ? 'Please select a location.' : null, 
                              id: 2,
                              selectedValue: _destValue,
                              onChange: changeDropdownSelection,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FormInput(
                            contextTextTheme: contextTextTheme, 
                            labelText: "Price", 
                            icon: Icons.payments,
                            inputController: _controller,
                            keyType: TextInputType.number,
                            validator: (value) => value=="" ? 'Please set a price.' : null,
                          )
                        ),
                      ]
                    ),
                    const SizedBox(height: 20),
                    Text('Trips', style: contextTextTheme.headlineSmall),
                    for(int i = 0; i < _days.length; i++)
                      CheckboxListTile(
                        title: Text(_days[i]),
                        value: _dayValues[i], 
                        onChanged: (values) {
                          setState(() {
                            _dayValues[i] = values!;
                          });
                        }
                      ),
                    const SizedBox(height: 30),
                    DeleteButton(data: _data),
                    SubmitButton(dayValues: _dayValues, days: _days, origin: _originValue, destination: _destValue, price: _controller.text, data: _data)
                  ]
                )
              )
            )
          )
        )
      )
    );
  }
}

class DropdownFormInput extends StatelessWidget {
  const DropdownFormInput({
    super.key,
    required this.contextTextTheme,
    required this.labelText,
    required this.icon,
    required this.validator,
    required this.items,
    required this.id,
    required this.onChange,
    required this.selectedValue,
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?)? validator;
  final int id;
  final Function onChange;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 10.0,
      shadowColor: const Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: DropdownButtonFormField(
        isExpanded: true,
        value: selectedValue,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(
            icon,
            color: Colors.black,
            size: 18,
            ),
          fillColor: const Color(0xFFF4F4F4),
          filled: true,
          hintText: labelText,
          hintStyle: contextTextTheme.labelLarge,
          counterText: "",
          contentPadding: const EdgeInsets.all(4.0),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ), 
        items: items, 
        validator: validator,
        onChanged: (value) {
          onChange(value, id);
        },
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.dayValues,
    required this.days,
    required this.origin,
    required this.destination,
    required this.price,
    required this.data,
  });

  final List<bool> dayValues;
  final List<String> days;
  final String origin;
  final String destination;
  final String price;
  final Map data;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness

    return Center(
      child: Container(
        width: (screenWidth * .75),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                ),
            ),
          ),
          onPressed: () async{
            if(_formKey.currentState!.validate() && context.mounted){

              final db = DBManager();
              //TODO change so that the companyID is set to the company that is logged in
              
              List<String> schedule = days.asMap().entries.where((element) => dayValues[element.key]).map((entry) => '"${entry.value}"').toList();
              
              var updatedata = await db.updateRouteAndSchedules(
                updateRoute: {
                  'origin': origin,
                  'destination': destination,
                  'price': price,
                  'routeID': data['routeID'],
              }, 
              updateSchedule: schedule);

              if(updatedata && context.mounted){
                Navigator.pop(context);
              }
            }
          },
          child: Text(
            "Save Changes",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class FormInput extends StatelessWidget {
  const FormInput({
    super.key,
    required this.contextTextTheme,
    required this.labelText,
    required this.icon,
    required this.inputController,
    required this.validator,
    this.password = false,
    this.keyType = TextInputType.text,
    this.text = "",
    this.enabled = true,
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final bool password;
  final TextEditingController inputController;
  final String? Function(String?)? validator;
  final TextInputType? keyType;
  final String? text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    text != "" ? inputController.text = text! : null;

    return Material(
      elevation: 10.0,
      shadowColor: const Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextFormField(
        controller: inputController,
        enabled: enabled,
        keyboardType: keyType,
        maxLength: 20,
        obscureText: password,
        validator: validator,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(
            icon,
            color: Colors.black,
            size: 18,
            ),
          fillColor: const Color(0xFFF4F4F4),
          filled: true,
          hintText: labelText,
          hintStyle: contextTextTheme.labelLarge,
          counterText: "",
          contentPadding: const EdgeInsets.all(4.0),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.data,
  });
  final Map data;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness

    return Center(
      child: Container(
        width: (_screenWidth * .75),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                ),
            ),
          ),
          onPressed: () async {
            var db = DBManager();
            var deleteVehicle = await db.delete('routes', where: 'id = "${data['routeID']}"', );
            if(deleteVehicle && context.mounted){
              Navigator.pop(context);
            }
          },
          child: Text(
            "Delete Vehicle",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}