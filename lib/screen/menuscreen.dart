import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuScreen extends StatefulWidget {
  final String foodName;
  final num calories;
  final String imageUrl;
  final List<String> ingredients;

  MenuScreen({
    required this.foodName,
    required this.calories,
    required this.imageUrl,
    required this.ingredients,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int plateCount = 1;
  late final String cachedImageUrl;
  List<Map<String, dynamic>> foodDiaryList = [];
  DateTime selectedDate = DateTime.now();
  String selectedMeal = 'เช้า';

  @override
  void initState() {
    super.initState();
    cachedImageUrl = widget.imageUrl;
  }

// ฟังก์ชันดึงข้อมูลอาการแพ้จาก Firestore
Future<List<String>> _getUserAllergies(String userId) async {
  List<String> allergies = [];
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      allergies = List<String>.from(userDoc['allergies'] ?? []);
    }
  } catch (e) {
    print("Error fetching allergies: $e");
  }
  return allergies;
}

  void _showFoodDiaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Center(
                  child: Text(
                    'บันทึกลง Food Diary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลือกวันที่',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                          Navigator.pop(context);
                          _showFoodDiaryDialog();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 1.5)),
                        ),
                        child: Text(
                          DateFormat('dd / MM / yyyy').format(selectedDate),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'เลือกมื้ออาหาร',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedMeal,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: ['เช้า', 'กลางวัน', 'เย็น', 'ของว่าง']
                          .map((meal) => DropdownMenuItem(
                                value: meal,
                                child: Text(meal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMeal = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ยกเลิก',
                              style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveToFoodDiary(selectedDate, selectedMeal);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveToFoodDiary(DateTime date, String meal) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  User? user = auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล")),
    );
    return;
  }

  // ดึงข้อมูลอาการแพ้ของผู้ใช้จาก Firestore
  List<String> allergies = await _getUserAllergies(user.uid);

  print("User Allergies: $allergies"); // ดีบักการดึงข้อมูลแพ้
  print("Ingredients: ${widget.ingredients}"); // ดีบักส่วนผสมในอาหาร

  // ตรวจสอบว่าอาหารมีส่วนผสมที่เป็นอันตรายหรือไม่
  for (String ingredient in widget.ingredients) {
    // ตัดแค่ชื่อของส่วนผสม (ไม่รวมปริมาณ)
    String ingredientName = ingredient.split(' ')[0]; 

    // เปรียบเทียบกับข้อมูล allergies
    for (var allergy in allergies) {
      if (ingredientName.contains(allergy)) {
        // แสดง AlertDialog ถ้ามีส่วนผสมที่แพ้
        _showAllergyAlert(ingredientName);
        return; // หยุดการบันทึกเมื่อพบส่วนผสมที่แพ้
      }
    }
  }

  // ถ้าไม่มีการแพ้ ให้ทำการบันทึกลง Food Diary
  String userId = user.uid;
  String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> newEntry = {
    'meal': meal,
    'food': widget.foodName,
    'calories': widget.calories * plateCount,
    'image': widget.imageUrl,
    'ingredients': widget.ingredients,
    'timestamp': DateTime.now(),
  };

  try {
    DocumentReference diaryRef = firestore
        .collection("users")
        .doc(userId)
        .collection("food_diary")
        .doc(formattedDate);

    DocumentSnapshot doc = await diaryRef.get();

    if (doc.exists) {
      await diaryRef.update({
        "entries": FieldValue.arrayUnion([newEntry])
      });
    } else {
      await diaryRef.set({
        "entries": [newEntry],
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึก ${widget.foodName} เรียบร้อยแล้ว'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
    );
  }
}

// ฟังก์ชันแสดงการแจ้งเตือนเมื่อพบการแพ้
void _showAllergyAlert(String ingredient) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('เแจ้งเตือนการแพ้อาหาร'),
        content: Text('คุณแพ้วัตถุดิบในอาหาร คือ\n $ingredient \nไม่สามารถบันทึกได้'),
        actions: [
          TextButton(
            child: Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final totalCalories = widget.calories * plateCount;
    final runMinutes = (totalCalories / 10).toStringAsFixed(0);
    final bikeMinutes = (totalCalories / 7).toStringAsFixed(0);
    final swimMinutes = (totalCalories / 13).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(
            fontFamily: 'Jua',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  cachedImageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 200, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.foodName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$totalCalories แคลอรี่',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (plateCount > 1) {
                          setState(() {
                            plateCount--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$plateCount',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          plateCount++;
                        });
                      },
                    ),
                  ],
                ),
                const Text(
                  'จาน',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            TextButton.icon(
  onPressed: _showIngredientsAlert,
  icon: Icon(Icons.info_outline, color: Colors.redAccent),
  label: Text(
    "ดูวัตถุดิบ",
    style: TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.bold,
    ),
  ),
),


            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  'ปริมาณแคลอรี่เทียบเท่าการออกกำลังกาย',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/run.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('วิ่ง $runMinutes นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/bike.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('ปั่นจักรยาน $bikeMinutes นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/swim.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('ว่ายน้ำ $swimMinutes นาที'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showFoodDiaryDialog,
              child: const Text('บันทึกลง Food Diary'),
            ),
          ],
        ),
      ),
    );
  }
  void _showIngredientsAlert() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('วัตถุดิบของ ${widget.foodName}'),
        content: widget.ingredients.isEmpty
            ? Text('ไม่มีข้อมูลวัตถุดิบ')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.ingredients.map((item) => Text("• $item")).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด'),
          ),
        ],
      );
    },
  );
}

}