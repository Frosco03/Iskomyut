library front_end;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    /*
      Login screen still incomplete. User input forms have been wrapped into their own widget (FormInput) for reusability of code
      as they share the same styles. Sizing is based on the width of the screen for responsive design, but has not been
      implemented yet. Perhaps one way to do is to adjust the size of the padding in the body portion of the Scaffold. 
    */

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
        physics: RangeMaintainingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth*.15),
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
                      child: FormInput(contextTextTheme: contextTextTheme, labelText: "First Name"),
                    ),
            
                    Spacer(),
            
                    Expanded(
                      flex: 4,
                      child: FormInput(contextTextTheme: contextTextTheme, labelText: "Last Name"),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                          flex: 4,
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Last Name"),
                        ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                          flex: 4,
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Password"),
                        ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                          flex: 4,
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Confirm Password"),
                        ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                          flex: 4,
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Mobile Number"),
                        ),
                  ],
                ),
              ],
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
  });

  final TextTheme contextTextTheme;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shadowColor: Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextField(
        maxLength: 20,
        decoration: InputDecoration(
          fillColor: Color(0xFFF4F4F4),
          filled: true,
          hintText: labelText,
          hintStyle: contextTextTheme.labelLarge,
          counterText: "",
          contentPadding: EdgeInsets.all(4.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}