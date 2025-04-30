import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> notifications = [];

  // ฟังก์ชันดึงข้อมูลแคลอรี่จาก Firestore สำหรับหลายวัน
  Future<void> _fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ใช้วันที่ที่ต้องการดึงข้อมูล (เช่น 29 และ 30 เมษายน)
    DateTime currentDate = DateTime.now();
    String currentDateFormatted = DateFormat('yyyy-MM-dd').format(currentDate);

    // กำหนดวันที่ให้ดึงข้อมูลย้อนหลัง
    List<String> dates = [];
    if (currentDate.day != 1) {
      // ดึงข้อมูลจากวันที่ 1 ถึงวันก่อนวันที่ปัจจุบัน
      for (int i = 1; i < currentDate.day; i++) {
        dates.add(DateFormat('yyyy-MM-dd').format(DateTime(currentDate.year, currentDate.month, i)));
      }
    }

    // ดึงข้อมูลแคลอรี่จาก Firestore สำหรับวันที่ที่ต้องการ
    for (String date in dates) {
      DocumentSnapshot foodDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_diary')
          .doc(date)
          .get();

      if (foodDoc.exists) {
        var data = foodDoc.data() as Map<String, dynamic>;
        var entries = data['entries'] ?? [];

        int dailyCalories = 0;

        // คำนวณแคลอรี่รวมจากทุกเมนูที่ทานในวันนั้น
        for (var entry in entries) {
          dailyCalories += (entry['calories'] != null ? (entry['calories'] as num).toInt() : 0);
        }

        setState(() {
          notifications.add({
            'date': DateFormat('d MMMM yyyy').format(DateTime.parse(date)),
            'text': 'แคลอรี่วันที่ $date คุณทานไปแล้ว $dailyCalories แคลอรี่ ',
            'type': 'calories',
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // เรียกใช้ฟังก์ชันดึงข้อมูลเมื่อเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    String? currentDate;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF4EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notification'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isNewDate = item['date'] != currentDate;
          currentDate = item['date'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNewDate)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    item['date']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Prompt',
                      color: Colors.black54,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Expanded(
                      child: Text(
                        item['text']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Prompt',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
