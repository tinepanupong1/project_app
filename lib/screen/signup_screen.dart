import 'package:flutter/material.dart';
import 'package:project_app/component/my_button.dart';
import 'package:project_app/screen/selectinfo.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get the User UID
      String uid = userCredential.user!.uid;

      // Store additional user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'gender': null, // จะได้รับค่าในหน้า SelectInfoScreen
        'age': null, // จะได้รับค่าในหน้า SelectInfoScreen
        'weight': null, // จะได้รับค่าในหน้า SelectInfoScreen
        'height': null, // จะได้รับค่าในหน้า SelectInfoScreen
        'disease': null, // จะได้รับค่าในหน้า SelectInfoScreen
        'allergies': null, // จะได้รับค่าในหน้า SelectInfoScreen
      });

      // Notify the user
      _showMyDialog('สมัครสมาชิกสำเร็จ!');

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectInfoScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      _showMyDialog('เกิดข้อผิดพลาด: ${e.message}');
    }
  }

  void _showMyDialog(String txtMsg) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 73, 194, 255),
          title: const Text('แจ้งเตือน'),
          content: Text(txtMsg),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Meal\n',
                          style: TextStyle(
                            fontFamily: 'GoblinOne',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(173, 212, 149, 1),
                          ),
                        ),
                        TextSpan(
                          text: 'Master',
                          style: TextStyle(
                            fontFamily: 'GoblinOne',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(173, 212, 149, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Registor...',
                      style: TextStyle(
                        fontFamily: 'Jua',
                        fontSize: 24,
                        color: Color.fromRGBO(42, 80, 90, 1),
                      ),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 100, // ปรับขนาดรูปภาพให้ใหญ่ขึ้น
                      backgroundImage: AssetImage('assets/images/food2.png'),
                      backgroundColor: Colors.transparent, // ตั้งค่า backgroundColor ให้เป็นโปร่งใส
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 300, // ปรับขนาดความกว้างให้แคบลง
                  height: 340, // ปรับขนาดความสูงตามต้องการ
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // เพิ่ม padding ให้ด้านบนและด้านล่าง
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 197, 66, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25), // เพิ่มพื้นที่ว่างด้านบน
                      MyTextField(
                        controller: nameController,
                        hintText: 'Name',
                        labelText: 'Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      MyTextField(
                        controller: emailController,
                        hintText: 'E-mail',
                        labelText: 'E-mail',
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      PasswordTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        labelText: 'Create password',
                      ),
                      const SizedBox(height: 20),
                      PasswordTextField(
                        controller: repasswordController,
                        hintText: 'Confirm password',
                        labelText: 'Repeat your password',
                      ),
                      const SizedBox(height: 20), // เพิ่มพื้นที่ว่างด้านล่าง
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // ปรับให้เป็นสี่เหลี่ยม
                    ),
                    side: const BorderSide(color: Colors.white, width: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String labelText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 270, // ปรับขนาดความกว้างให้สั้นลง
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final String labelText;

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 270, // ปรับขนาดความกว้างให้สั้นลง
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: GestureDetector(
              onTap: _toggleObscureText,
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
