import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // เชื่อมต่อ Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TineScreen(),
    );
  }
}

class TineScreen extends StatefulWidget {
  @override
  _TineScreenState createState() => _TineScreenState();
}

class _TineScreenState extends State<TineScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers สำหรับ TextFields
  TextEditingController foodNameController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();

  Future<void> addFoodMenu() async {
  try {
    // ตรวจสอบว่ากรอกข้อมูลครบทุกฟิลด์หรือไม่
    if (foodNameController.text.isNotEmpty &&
        caloriesController.text.isNotEmpty &&
        ingredientsController.text.isNotEmpty) {

      // แปลงค่าจาก TextField
      String foodName = foodNameController.text;
      double calories = double.parse(caloriesController.text); // แปลงแคลอรี่เป็นตัวเลขชนิด double
      List<String> ingredients = ingredientsController.text.split(','); // แยกรายการวัตถุดิบ

      // เพิ่มข้อมูลลงใน Firestore
      await _firestore.collection('disease')
        .doc('Hypertension')
        .collection('snacks')
        .add({
          'food_name': foodName,
          'calories': calories,
          'ingredients': ingredients
        }).then((value) {
          print("เพิ่มข้อมูลเมนูสำเร็จ");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่มข้อมูลสำเร็จ')),
          );
        }).catchError((error) {
          print("เกิดข้อผิดพลาด: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
      );
    }
  } catch (e) {
    print("เกิดข้อผิดพลาด: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มเมนูอาหาร'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: foodNameController,
              decoration: InputDecoration(labelText: 'ชื่ออาหาร'),
            ),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'แคลอรี่'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: 'วัตถุดิบ (แยกด้วยคอมม่า)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFoodMenu,
              child: Text('เพิ่มเมนู'),
            ),
          ],
        ),
      ),
    );
  }
}
