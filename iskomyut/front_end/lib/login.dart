library front_end;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:db_integration/db_integration.dart';
import 'package:flutter/widgets.dart';
import 'package:crypto/crypto.dart';

final _formKey = GlobalKey<FormState>();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  /*
    Create a list of TextEditingControllers to take the inputs of the TextFields
    So that we DRY
  */
  final List<TextEditingController> _fieldValueControllers = List.generate(2, (i) => TextEditingController());
  bool _invalidCredentials = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    for(TextEditingController controller in _fieldValueControllers){
      print("disposed!");
      controller.dispose();
    }
    super.dispose();  
  }

  String? validatePhone(String? phone){
    RegExp phoneNo = RegExp(r'\d{11}');
    final isPhoneValid = phoneNo.hasMatch(phone ?? '');

    if(!isPhoneValid){
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  void _showInvalidLogin(){
    setState(() {
      _invalidCredentials = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
      Workaround for issue: keyboard blocking input lines
      Workaround link: https://stackoverflow.com/questions/67571423/bottom-overflowed-by-x-pixels-when-showing-keyboard
      Made the column have the same height as the screen size and wrapped it with a SingleChildScrollView so that the
      display automatically scrolls up when opening the keyboard, preventing input fields from being blocked by the keyboard.
    */

    double screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness
    final contextTextTheme = Theme.of(context).textTheme;


    return Scaffold(
      body: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth*.10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text("Log in", style: contextTextTheme.headlineLarge),
                    ],
                  ),
                  SizedBox(height:30,),
                  Row(
                    children: [
                      Expanded(
                            flex: 4,
                            child: FormInput(
                              contextTextTheme: contextTextTheme, 
                              labelText: "Mobile Number", 
                              icon: Icons.phone_iphone,
                              inputController: _fieldValueControllers[0],
                              validator: validatePhone,
                          )
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
                              labelText: "Password", 
                              icon: Icons.lock, 
                              password: true,
                              inputController: _fieldValueControllers[1],
                              validator: (value) => value=="" ? 'Please fill out this field.' : null),
                          ),
                    ],
                  ),
                  if(_invalidCredentials == true) ...[
                    SizedBox(height:30,),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              color: Color(0x32F48B29),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Incorrect Credentials", 
                                style: contextTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  SubmitButton(controllers: _fieldValueControllers, showInvalidLogin: _showInvalidLogin),
                ],
              ),
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
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final bool password;
  final TextEditingController inputController;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shadowColor: Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextFormField(
        controller: inputController,
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
    required this.showInvalidLogin
  });

  final List<TextEditingController> controllers;
  final VoidCallback showInvalidLogin; //callback function to change the state of the login page

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
          onPressed: () async {
            if(_formKey.currentState!.validate()){
              String phoneNo = controllers[0].text;
              String password = md5.convert(utf8.encode(controllers[1].text)).toString();
              
              var db = DBManager();
              var inputIsCorrect = await db.isPresent('passengers', where: 'phone = "$phoneNo" AND password = "$password"');
              if (inputIsCorrect == true && context.mounted){
                Navigator.pushReplacementNamed(context, '/dash');
              }
              else{
                showInvalidLogin();
              }
            }
            
          },
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