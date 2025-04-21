import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_app/screen/signup_screen.dart';
import 'package:project_app/screen/homescreen.dart';
import 'package:project_app/screen/forgotpassword.dart'; // ✅ เพิ่ม import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  // ฟังก์ชันเข้าสู่ระบบ
  signInWithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      _showErrorDialog(e.message ?? 'Login failed');
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 120,
                backgroundImage: AssetImage('assets/images/food1.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Login...',
                style: TextStyle(
                  fontFamily: 'Jua',
                  fontSize: 24,
                  color: Color.fromARGB(255, 42, 80, 90),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "E-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300,
                child: TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
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
                  side: const BorderSide(color: Colors.white, width: 2.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  minimumSize: const Size(10, 30),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 ลิงก์ไปหน้าลืมรหัสผ่าน
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              // 🔹 ลิงก์ไปหน้า Register
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Or Register",
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 24,
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
