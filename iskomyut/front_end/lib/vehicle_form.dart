library front_end;

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VehicleForm extends StatefulWidget {
  const VehicleForm({super.key});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {

  final List<TextEditingController> _fieldValueControllers = List.generate(3, (i) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final contextTextTheme = Theme.of(context).textTheme;

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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: FormInput(
                          contextTextTheme: contextTextTheme, 
                          labelText: "Model", 
                          icon: Icons.airport_shuttle,
                          inputController: _fieldValueControllers[0],
                          validator: (value) => null, //TODO
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: FormInput(
                          contextTextTheme: contextTextTheme, 
                          labelText: "Plate No", 
                          icon: Icons.pin,
                          inputController: _fieldValueControllers[1],
                          validator: (value) => null, //TODO
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: FormInput(
                          contextTextTheme: contextTextTheme, 
                          labelText: "Capacity", 
                          icon: Icons.groups,
                          inputController: _fieldValueControllers[2],
                          validator: (value) => null, //TODO
                          keyType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SubmitButton(controllers: _fieldValueControllers),
                ],
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
    this.keyType = TextInputType.text
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final bool password;
  final TextEditingController inputController;
  final String? Function(String?)? validator;
  final TextInputType? keyType;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shadowColor: Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextFormField(
        controller: inputController,
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
          fillColor: Color(0xFFF4F4F4),
          filled: true,
          hintText: labelText,
          hintStyle: contextTextTheme.labelLarge,
          counterText: "",
          contentPadding: const EdgeInsets.all(4.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.controllers,
  });

  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness

    return Center(
      child: Container(
        width: (_screenWidth * .75),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                ),
            ),
          ),
          onPressed: () {},
          child: Text(
            "Submit",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}