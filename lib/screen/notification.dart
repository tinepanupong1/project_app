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

  Future<void> _fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🔹 ดึงข้อมูลอาการแพ้
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    List<dynamic> allergies = [];
    var rawAllergies = userDoc['allergies'];
    if (rawAllergies is List) {
      allergies = rawAllergies;
    } else if (rawAllergies is String) {
      allergies = [rawAllergies];
    }

    print("🐔 User Allergies: $allergies");

    // 🔹 ดึงข้อมูลเมนูของวันนี้
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot foodDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('food_diary')
        .doc(dateKey)
        .get();

    if (!foodDoc.exists) {
      print("📭 ไม่มีข้อมูล food_diary สำหรับวันที่ $dateKey");
      return;
    }

    var data = foodDoc.data() as Map<String, dynamic>;
    List<dynamic> entries = data['entries'] ?? [];

    List<Map<String, String>> tempNoti = [];

    for (var entry in entries) {
      String food = entry['food'] ?? 'ไม่ทราบชื่ออาหาร';
      List<dynamic> ingredients = entry['ingredients'] ?? [];

      bool foundAllergy = false;

      for (var ingredient in ingredients) {
        for (var allergy in allergies) {
          if (ingredient.toString().contains(allergy)) {
            print("⚠️ พบสารก่อแพ้: $allergy ในเมนู $food");

            tempNoti.add({
              'date': DateFormat('dd MMMM yyyy').format(DateTime.now()),
              'text': 'คุณทานเมนู "$food" ที่มีส่วนผสมที่คุณแพ้: $allergy',
              'time': DateFormat('HH:mm').format(DateTime.now()),
              'type': 'alert',
            });

            foundAllergy = true;
            break; // หยุดตรวจ allergy ใน ingredient นี้
          }
        }
        if (foundAllergy) break; // หยุดตรวจ ingredient ถ้าเจอแล้ว
      }
    }

    setState(() {
      notifications.addAll(tempNoti);
    });
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
                  color: Colors.pink[100],
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
