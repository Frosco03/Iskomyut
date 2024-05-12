library front_end;


import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    /*
      Workaround for issue: keyboard blocking input lines
      Workaround link: https://stackoverflow.com/questions/67571423/bottom-overflowed-by-x-pixels-when-showing-keyboard
      Made the column have the same height as the screen size and wrapped it with a SingleChildScrollView so that the
      display automatically scrolls up when opening the keyboard, preventing input fields from being blocked by the keyboard.
    */

    double _screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness
    final contextTextTheme = Theme.of(context).textTheme;
    final fieldValueController = TextEditingController(); //controller to retrieve value of the TextField inputs
    
    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      fieldValueController.dispose();
      super.dispose();  
    }

    return Scaffold(
      body: SingleChildScrollView(
        physics: RangeMaintainingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: EdgeInsets.all(_screenWidth*.10),
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
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Mobile Number", icon: Icons.phone_iphone),
                        ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                          flex: 4,
                          child: FormInput(contextTextTheme: contextTextTheme, labelText: "Password", icon: Icons.lock, password: true,),
                        ),
                  ],
                ),
                SizedBox(height: 20),
                SubmitButton(),
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
    required this.icon,
    this.password = false,
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final bool password;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shadowColor: Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextField(
        maxLength: 20,
        obscureText: password,
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
  });

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness

    return Center(
      child: Container(
        width: (_screenWidth * .75),
        child: ElevatedButton(
          child: Text(
            "Submit",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                ),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/dash');
          },
        ),
      ),
    );
  }
}