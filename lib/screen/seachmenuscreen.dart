import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menuscreen.dart'; // เพิ่มไฟล์ MenuScreen ที่สร้างไว้

class SearchMenuScreen extends StatefulWidget {
  @override
  _SearchMenuScreenState createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends State<SearchMenuScreen> {
  String? selectedDisease;
  List<Map<String, dynamic>> menuItems = [];
  List<String> favoriteFoods = []; // รายการอาหารที่ชอบ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thai Food',
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
            Navigator.pop(context); // ปิดหน้าจอ
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // ส่วนของการค้นหาเมนู
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search Menu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () {
                    _showFilterDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final foodName = menuItems[index]['food_name'];
                  final calories = menuItems[index]['calories'];
                  final isFavorite = favoriteFoods.contains(foodName);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            foodName: foodName,
                            calories: calories,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // สีพื้นหลังแถบ
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2), // เงาใต้แถบ
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 20,
                                backgroundImage: AssetImage('assets/images/dish.png'), // แสดงภาพ Dish.png
                              ),
                              const SizedBox(width: 10),
                              Text(
                                foodName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '$calories kcal',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isFavorite) {
                                      favoriteFoods.remove(foodName);
                                    } else {
                                      favoriteFoods.add(foodName);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงหน้าจอเลือกโรค
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกโรค'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('โรคความดันโลหิตสูง'),
                onTap: () {
                  _filterMenuByDisease('Hypertension');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('โรคอ้วน'),
                onTap: () {
                  _filterMenuByDisease('Obesity');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('โรคไต'),
                onTap: () {
                  _filterMenuByDisease('kidney disease');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันดึงข้อมูลเมนูตามโรค
  void _filterMenuByDisease(String disease) async {
    List<Map<String, dynamic>> meals = [];
    List<Map<String, dynamic>> snacks = [];

    // ดึงข้อมูลจาก Firestore ของ meals
    var mealsSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('meals')
        .get();

    for (var doc in mealsSnapshot.docs) {
      meals.add(doc.data());
    }

    // ดึงข้อมูลจาก Firestore ของ snacks
    var snacksSnapshot = await FirebaseFirestore.instance
        .collection('disease')
        .doc(disease)
        .collection('snacks')
        .get();

    for (var doc in snacksSnapshot.docs) {
      snacks.add(doc.data());
    }

    // รวม meals และ snacks แล้วจัดเรียงตามชื่อเมนู (food_name) จาก ก-ฮ
    List<Map<String, dynamic>> allItems = [...meals, ...snacks];
    allItems.sort((a, b) => a['food_name'].compareTo(b['food_name']));

    setState(() {
      menuItems = allItems;
    });
  }
}
