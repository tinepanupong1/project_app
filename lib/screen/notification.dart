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

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // ฟังก์ชันดึงข้อมูลการแจ้งเตือน
  Future<void> _fetchNotifications() async {
    // ดึงข้อมูลผู้ใช้ที่ล็อกอิน
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ดึงข้อมูลอาการแพ้จาก Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    List<dynamic> allergies = userDoc['allergies'] ?? [];
    print("User Allergies: $allergies");

    // ดึงข้อมูลบันทึกอาหารจาก Firestore
    QuerySnapshot foodDiarySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('food_diary')
        .get();

    for (var doc in foodDiarySnapshot.docs) {
      List<dynamic> entries = doc['entries'] ?? [];
      
      // ลูปผ่านทุกเมนูอาหาร
      for (var entry in entries) {
        List<dynamic> ingredients = entry['ingredients'] ?? [];
        print("Ingredients for ${entry['food']}: $ingredients");

        // เปรียบเทียบว่า ingredients มีอาหารที่แพ้หรือไม่
        for (var ingredient in ingredients) {
          // ตรวจสอบว่า `ingredients` ตรงกับ `allergies` โดยตรง
          for (var allergy in allergies) {
            if (ingredient.toString().contains(allergy)) {
              setState(() {
                // ถ้าพบอาหารที่แพ้, ให้แสดงการแจ้งเตือน
                notifications.add({
                  'date': DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  'text': 'คุณทานอาหารที่แพ้: $allergy',
                  'time': DateFormat('HH:mm').format(DateTime.now()),
                  'type': 'alert',
                });
              });
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentDate;

    return Scaffold(
      backgroundColor: Color(0xFFFDF4EB),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF4EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('การแจ้งเตือน'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Prompt',
                      color: Colors.black54,
                    ),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.pink[100], // สำหรับการแจ้งเตือนอาหารที่แพ้
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['text']!,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Prompt',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      item['time']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Prompt',
                        fontSize: 14,
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
