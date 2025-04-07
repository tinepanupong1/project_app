import 'package:flutter/material.dart';
import 'package:project_app/screen/waterscreen.dart';
import 'package:project_app/screen/weight_control_screen.dart';
import 'package:project_app/screen/maintain_weight_screen.dart';
import 'package:project_app/screen/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            final String goalType =
                userData?['goalType'] ?? 'ยังไม่ได้ตั้งเป้าหมาย';

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                Text(
                  'เป้าหมายปัจจุบัน: $goalType',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // ปุ่มต่าง ๆ
                goalButton(
                  context,
                  icon: Icons.monitor_weight,
                  text: 'ควบคุมน้ำหนัก',
                  color: Colors.pink.shade100,
                  iconColor: Colors.pink.shade600,
                  destination: WeightControlScreen(),
                ),
                const SizedBox(height: 20),
                goalButton(
                  context,
                  icon: Icons.verified,
                  text: 'รักษาน้ำหนัก',
                  color: Colors.green.shade100,
                  iconColor: Colors.green.shade600,
                  destination: MaintainWeightScreen(),
                ),
                const SizedBox(height: 20),
                goalButton(
                  context,
                  icon: Icons.health_and_safety,
                  text: 'ดื่มน้ำให้เพียงพอ',
                  color: Colors.orange.shade100,
                  iconColor: Colors.orange.shade600,
                  destination: Waterscreen(),
                ),
                const SizedBox(height: 20),
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
            );
          },
        ),
      ),
    );
  }

  Widget goalButton(BuildContext context,
      {required IconData icon,
      required String text,
      required Color color,
      required Color iconColor,
      required Widget destination}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
