import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_app/component/my_button.dart';
import 'package:project_app/component/my_textfield.dart';
import 'package:project_app/screen/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final repasswordController = TextEditingController();

  signUpWithEmail() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _showMyDialog('Sign up successfully!');
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  void _showMyDialog(String txtMsg) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 73, 194, 255),
            title: const Text('AlertDialog Title'),
            content: Text(txtMsg),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
    padding: const EdgeInsets.only(top: 100.0), 
      child: Container(
       
        child: Form(
          child: Column(
            children: [
              
                Center(
            child: Image.asset('assets/images/food.png', width: 200),
          ),
              const SizedBox(
                height: 60,
              ),
              MyTextField(
                  controller: nameController,
                  hintText: 'Enter your name.',
                  obscureText: false,
                  labelText: ''),
                  
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: emailController,
                  hintText: 'Enter your Email.',
                  obscureText: false,
                  labelText: ''),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: passwordController,
                  hintText: 'Enter your password.',
                  obscureText: true,
                  labelText: ''),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: repasswordController,
                  hintText: 'Enter your password again.',
                  obscureText: true,
                  labelText: ''),
              const SizedBox(
                height: 20,
              ),
              MyButton(onTap: signUpWithEmail, hintText: "Sign up"),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  const SizedBox(
                    width: 2,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen1(),
                          ));
                    },
                
                    child: Text(
                      'Already have an account? Sign in.',
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.displaySmall,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: const Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    ),);
  }
}
