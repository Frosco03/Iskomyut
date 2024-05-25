library front_end;

import 'package:db_integration/db_integration.dart';
import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  State<AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {

  final List<TextEditingController> _fieldValueControllers = List.generate(2, (i) => TextEditingController());
  List<DropdownMenuItem<String>> dropdownItems = [];
  var db = DBManager();
  late List models;
  late String selectedModel;
  late int listIndex = 0; //index of list to access map of selectedmodel
  bool isReady = false;

  void changeSelection(String value, int index){
    selectedModel = value;
    listIndex = index;
  }

  @override
  void initState() {
    super.initState();

    /*
      Workaround to use an async function in initstate. Waits for the async function to complete 
      and sets the value to the response (list).
    */
    getModels().then((response) {
      setState((){
        models = response;

        dropdownItems = List.generate(
          models.length,
          (index) => DropdownMenuItem(
            value: models[index]['modelName'],
            child: Text(models[index]['modelName'])
          )
        );

        isReady = true;
      });
    }); 
  }

  Future<List> getModels() async{
    List models = await db.getValues('vehicle_models');
    return models;
  }

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

    if(!isReady){
      return Container(decoration: const BoxDecoration(color: Colors.white),);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Vehicle"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*.15),
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
                              labelText: "Model", 
                              items: dropdownItems,
                              icon: Icons.airport_shuttle,
                              validator: (value) => value==null ? 'Please select a model.' : null, 
                              modelsList: models,
                              inputController: _fieldValueControllers[1],
                              changeSelection: changeSelection, //pass the input controller of capacity field 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: FormInput(
                              contextTextTheme: contextTextTheme, 
                              labelText: "Plate No", 
                              icon: Icons.pin,
                              inputController: _fieldValueControllers[0],
                              validator: (value) => value=="" ? 'Please fill out this field.' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 3,
                            child: FormInput(
                              contextTextTheme: contextTextTheme, 
                              labelText: "Capacity", 
                              icon: Icons.groups,
                              inputController: _fieldValueControllers[1],
                              validator: (value) => value=="" ? 'Please fill out this field.' : null,
                              keyType: TextInputType.number,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SubmitButton(controllers: _fieldValueControllers, selectedModelID: models[listIndex]['id']),
                    ],
                  ),
                ),
              ),
            ),
          )
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

class DropdownFormInput extends StatelessWidget {
  const DropdownFormInput({
    super.key,
    required this.contextTextTheme,
    required this.labelText,
    required this.icon,
    required this.validator,
    required this.items,
    required this.modelsList,
    required this.inputController,
    required this.changeSelection,
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?)? validator;
  final List modelsList;
  final TextEditingController inputController;
  final Function(String, int) changeSelection;

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 10.0,
      shadowColor: const Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: DropdownButtonFormField(
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
          //Change the state of the 'capacity' field by changing the text in the controller assigned to the field
          int index = modelsList.indexWhere((map) => map['modelName'] == value);
          inputController.text = modelsList[index]['capacity'].toString();
          changeSelection(value!, index); //Callback to the function in the parent to change the selectedmodel variable
         },
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.controllers,
    required this.selectedModelID,
  });

  final List<TextEditingController> controllers;
  final int selectedModelID;

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

              var db = DBManager();
              //TODO change so that the companyID is set to the company that is logged in
              var insertData = await db.insert('vehicles', columns: ['companyId', 'model', 'plate'], values: [1, selectedModelID, '"${controllers[0].text}"']);

              if(insertData && context.mounted){
                Navigator.pop(context);
              }
            }
          },
          child: Text(
            "Add New Vehicle",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}