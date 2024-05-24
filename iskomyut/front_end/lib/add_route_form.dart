library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class AddRouteForm extends StatefulWidget {
  const AddRouteForm({super.key});

  @override
  State<AddRouteForm> createState() => _AddRouteFormState();
}

class _AddRouteFormState extends State<AddRouteForm> {
  bool _isReady = false;
  List<DropdownMenuItem<String>> _dropdownItems = [];
  final _db = DBManager();
  final List<String> _days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  List<bool> _dayValues = [false, false, false, false, false, false, false];
  String _originValue = "", _destValue = "";
  final TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getTerminals().then((response) {
      setState(() {
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

    if(!_isReady){
      return Container(decoration: const BoxDecoration(color: Colors.white),);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Route"),
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
                    SubmitButton(dayValues: _dayValues, days: _days, origin: _originValue, destination: _destValue, price: _controller.text)
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
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?)? validator;
  final int id;
  final Function onChange;

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 10.0,
      shadowColor: const Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: DropdownButtonFormField(
        isExpanded: true,
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
  });

  final List<bool> dayValues;
  final List<String> days;
  final String origin;
  final String destination;
  final String price;

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
              
              var insertdata = await db.insertRouteAndSchedules(
                insertRoute: {
                  'origin': origin,
                  'destination': destination,
                  'serviceProvider': '1',
                  'price': price,
              }, 
              insertSchedule: schedule);

              if(insertdata && context.mounted){
                Navigator.pop(context);
              }
            }
          },
          child: Text(
            "Add New Route",
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