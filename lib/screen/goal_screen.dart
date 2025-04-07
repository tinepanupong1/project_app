import 'package:flutter/material.dart';
import 'package:project_app/screen/waterscreen.dart';
import 'package:project_app/screen/weight_control_screen.dart';
import 'package:project_app/screen/maintain_weight_screen.dart';
import 'package:project_app/screen/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String currentGoalType = ''; // ตัวแปรเก็บ goalType

  @override
  void initState() {
    super.initState();
    fetchGoalType(); // เรียกใช้ฟังก์ชันดึงค่า goalType
  }

  Future<void> fetchGoalType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDocument.exists) {
        setState(() {
          // หากใน Firebase ไม่มีฟิลด์ goalType ให้กำหนดค่าเริ่มต้นตามต้องการ เช่น "ยังไม่ได้ตั้งเป้าหมาย"
          currentGoalType = userDocument['goalType'] ?? 'ยังไม่ได้ตั้งเป้าหมาย';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E6),
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    },
  ),
  title: const Text('Goal'),
  centerTitle: true,
  titleTextStyle: const TextStyle(
    fontFamily: 'Jua',
    fontSize: 30,
    fontWeight: FontWeight.w500,
    color: Color(0xFF2A505A),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลางหน้าจอ
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/goalH.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // แสดง goalType ที่ดึงได้จาก Firebase
            Text(
              'เป้าหมายปัจจุบัน: $currentGoalType',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม ควบคุมน้ำหนัก
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeightControlScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight, color: Colors.pink.shade600),
                    const SizedBox(width: 10),
                    const Text(
                      'ควบคุมน้ำหนัก',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่ม รักษาน้ำหนัก
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MaintainWeightScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade600),
                    const SizedBox(width: 10),
                    const Text(
                      'รักษาน้ำหนัก',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่ม ดื่มน้ำ
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Waterscreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.orange.shade600),
                    const SizedBox(width: 10),
                    const Text(
                      'ดื่มน้ำให้เพียงพอ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่มย้อนกลับ
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.arrow_back),
            ),
          ],
        ),
      ),
    );
  }
}
