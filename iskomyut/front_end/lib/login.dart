library front_end;

import 'package:flutter/material.dart';
import 'package:db_integration/db_integration.dart';
import 'package:flutter/widgets.dart';

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

    double _screenWidth = MediaQuery.of(context).size.width; //Get the width of the screen for responsiveness
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
                          child: FormInput(
                            contextTextTheme: contextTextTheme, 
                            labelText: "Mobile Number", 
                            icon: Icons.phone_iphone,
                            inputController: _fieldValueControllers[0],),
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
                            inputController: _fieldValueControllers[1],),
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
    );
  }
}

class FormInput extends StatefulWidget {
  const FormInput({
    super.key,
    required this.contextTextTheme,
    required this.labelText,
    required this.icon,
    required this.inputController,
    this.password = false,
  });

  final TextTheme contextTextTheme;
  final String labelText;
  final IconData icon;
  final bool password;
  final TextEditingController inputController;

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shadowColor: Color(0x46000000),
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.transparent,
      child: TextFormField(
        controller: widget.inputController,
        maxLength: 20,
        obscureText: widget.password,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(
            widget.icon,
            color: Colors.black,
            size: 18,
            ),
          fillColor: Color(0xFFF4F4F4),
          filled: true,
          hintText: widget.labelText,
          hintStyle: widget.contextTextTheme.labelLarge,
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
            String username = controllers[0].text;
            String password = controllers[1].text;
            var db = DBManager();
            var inputIsCorrect = await db.isPresent('service_providers', where: 'username = "$username" AND password = "$password"');
            if (inputIsCorrect == true && context.mounted){
              Navigator.pushNamed(context, '/dash');
            }
            else{
              showInvalidLogin();
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