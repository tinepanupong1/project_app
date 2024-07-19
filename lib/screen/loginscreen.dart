import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_app/screen/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text Editing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign In with Email method
  signInWithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E8), // เปลี่ยนสีพื้นหลังให้ตรงกับภาพ
      body: Center(
        child: SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อให้หน้าจอเลื่อนเมื่อมีเนื้อหาเกินขนาด
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft, // จัดตำแหน่งให้เป็นซ้ายบน
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // เพิ่ม padding ด้านซ้ายและขวา
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Meal\n', // เพิ่ม \n เพื่อให้ "Master" อยู่บรรทัดถัดไป
                          style: TextStyle(
                            fontFamily: 'GoblinOne',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(173, 212, 149, 1) // ปรับสีตามภาพ
                          ),
                        ),
                        TextSpan(
                          text: 'Master',
                          style: TextStyle(
                            fontFamily: 'GoblinOne',
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(173, 212, 149, 1), // ปรับสีตามภาพ
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // เพิ่มช่องว่างระหว่างส่วนต่างๆ
              const Center(
                child: CircleAvatar(
                  radius: 120, // ปรับขนาดรูปภาพให้ใหญ่ขึ้น
                  backgroundImage: AssetImage('assets/images/food1.png'),
                  backgroundColor: Colors.transparent, // ตั้งค่า backgroundColor ให้เป็นสีโปร่งใส
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login...',
                style: TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 24,
                  color: Color.fromARGB(255, 42, 80, 90), // เปลี่ยนสีของข้อความ
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300, // ตั้งค่าความกว้างของ Container
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "E-mail",
                    filled: true,
                    fillColor: Colors.white, // เปลี่ยนสีพื้นหลังของ TextField
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), // ปรับขนาด padding
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300, // ตั้งค่าความกว้างของ Container
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white, // เปลี่ยนสีพื้นหลังของ TextField
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), // ปรับขนาด padding
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signInWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  side: BorderSide(color: Colors.white, width: 2.0),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // ปรับความสูงของปุ่ม
                  minimumSize: Size(10, 30), // ปรับขนาดขั้นต่ำของปุ่ม
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 30, // ปรับขนาดตัวอักษรให้ใหญ่ขึ้น
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Forgot password action
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Or Register",
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 24, // ปรับขนาดให้สอดคล้องกับภาพ
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
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
