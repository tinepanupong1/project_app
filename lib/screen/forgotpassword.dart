import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ฟังก์ชันส่งคำร้องขอเปลี่ยนรหัสผ่าน
  Future<void> submitRequest() async {
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();

    try {
      // ค้นหาผู้ใช้จากอีเมล
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        _showDialog("ไม่พบบัญชีนี้");
        return;
      }

      // ตรวจสอบเบอร์โทรศัพท์
      var userData = snapshot.docs.first.data() as Map<String, dynamic>;
      if (userData['phone'] != phone) {
        _showDialog("เบอร์โทรไม่ตรงกับที่ลงทะเบียนไว้");
        return;
      }

      // ✅ ส่งคำร้องใน Firestore สำหรับแอดมินตรวจสอบ
      await FirebaseFirestore.instance.collection('password_requests').add({
        'email': email,
        'phone': phone,
        'status': 'pending', // สถานะเริ่มต้น
        'timestamp': Timestamp.now(),
      });

      _showDialog("ส่งคำร้องขอเปลี่ยนรหัสสำเร็จ! รอแอดมินดำเนินการ");

    } catch (e) {
      _showDialog("เกิดข้อผิดพลาด: $e");
    }
  }

  // ฟังก์ชันแสดงหน้าต่างแจ้งเตือน
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("แจ้งเตือน"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E8),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Email", style: TextStyle(fontSize: 16)),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'กรอกอีเมล',
              ),
            ),
            const SizedBox(height: 20),
            const Text("Phone Number", style: TextStyle(fontSize: 16)),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'กรอกเบอร์โทรศัพท์',
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
