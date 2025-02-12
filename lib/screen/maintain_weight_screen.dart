//maintain_weight_screen.dart
import 'package:flutter/material.dart';
import 'package:project_app/component/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaintainWeightScreen extends StatefulWidget {
  @override
  State<MaintainWeightScreen> createState() => _MaintainWeightScreenState();
}

class _MaintainWeightScreenState extends State<MaintainWeightScreen> {
  double currentWeight = 0.0;
  String goalType = "รักษาน้ำหนัก";

  @override
  void initState() {
    super.initState();
    fetchUserData(); // ดึงข้อมูลจาก Firebase เมื่อเปิดหน้าจอ
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDocument.exists) {
        setState(() {
          currentWeight = (userDocument['weight'] as num?)?.toDouble() ?? 0.0;
          goalType = userDocument['goalType'] ?? "รักษาน้ำหนัก";
        });
      }
    }
  }

  Future<void> saveGoalType() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'goalType': "รักษาน้ำหนัก",
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกเป้าหมายรักษาน้ำหนักเรียบร้อย')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            const Text('รักษาน้ำหนัก', style: TextStyle(color: Colors.black)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        // ✅ ป้องกัน Overflow
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                  width: 200,
                  child: Image(image: AssetImage('assets/images/w.png'))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.9, // ปรับอัตโนมัติ
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 202, 228, 235),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "น้ำหนักปัจจุบันของคุณ",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28), //โค้ง
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // เงา
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        '${currentWeight.toStringAsFixed(1)} กก.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('รักษาน้ำหนักเพื่อคงระดับน้ำหนักปัจจุบัน'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveGoalType,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundPink,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'บันทึกเป้าหมาย',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 