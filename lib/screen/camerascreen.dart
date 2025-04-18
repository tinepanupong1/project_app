import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _responseText = 'กรุณาอัปโหลดรูปภาพอาหาร'; 
  bool _isAnalyzing = false;
  DateTime selectedDate = DateTime.now(); 
  String selectedMeal = 'เช้า'; 
  String foodName = '';
  int calories = 0;
  String imageUrl = '';

  // ฟังก์ชันเลือกภาพจากโทรศัพท์
  Future<void> _pickImage() async {
    setState(() {
      _responseText = 'Processing...';
      _isAnalyzing = true;
    });

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _analyzeFoodWithGemini(_image!);
    }
  }

  // ฟังก์ชันการวิเคราะห์อาหารจาก Gemini
  Future<void> _analyzeFoodWithGemini(File imageFile) async {
    final String apiKey = 'AIzaSyB4rI-ch_vqO4dAlwT1X4sLRI2jvaJoByU'; // ใช้ API Key ของ Gemini ที่ถูกต้อง
    final GenerativeModel model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = 'image/jpeg'; 

      final content = [
        Content(
          'user',
          [
            TextPart(
              'ช่วยวิเคราะห์อาหารในรูปภาพนี้ และแสดงข้อมูลในรูปแบบสั้นๆ ตามนี้:\n'
              'ชื่อเมนูอาหาร: <ชื่อเมนู>\n'
              'ส่วนประกอบ:\n'
              '  - <ส่วนประกอบ 1>: <ปริมาณ> กรัม\n'
              '  - <ส่วนประกอบ 2>: <ปริมาณ> กรัม\n'
              '  - ...\n'
              'จำนวนแคลอรี่ทั้งหมด: <จำนวนแคลอรี่> แคลอรี่\n'
              'กรุณาแสดงข้อมูลทั้งหมดในลักษณะนี้โดยไม่ต้องอธิบายเพิ่มเติม',
            ),
            DataPart(mimeType, bytes),
          ],
        ),
      ];

      final response = await model.generateContent(content);

      if (response.text != null) {
        setState(() {
          _responseText = response.text!;
          _isAnalyzing = false;
        });

        try {
          final lines = _responseText.split("\n");

          foodName = lines[0].split(":")[1].trim();  // ดึงชื่ออาหาร
          final ingredients = [];
          for (int i = 1; i < lines.length - 1; i++) {
            ingredients.add(lines[i].trim());
          }

          // ดึงแคลอรี่และลบตัวอักษรที่ไม่ใช่ตัวเลข
          String caloriesString = "ข้อมูลแคลอรี่ไม่พบ";
          for (var line in lines) {
            if (line.contains("แคลอรี่")) {
              caloriesString = line.split(":")[1].trim(); // Extract calories part
              break;
            }
          }

          // ลบตัวอักษรที่ไม่ใช่ตัวเลขจากแคลอรี่
          final RegExp regExp = RegExp(r'[^0-9]');
          String cleanedCalories = caloriesString.replaceAll(regExp, '');

          // แปลงแคลอรี่ที่ได้เป็นตัวเลข
          calories = int.tryParse(cleanedCalories) ?? 0; // ถ้าไม่สำเร็จจะใช้ 0 เป็นค่าเริ่มต้น

          // อัปโหลดภาพไปยัง Firebase Storage
          imageUrl = await _uploadImageToFirebase(imageFile);

        } catch (e) {
          print("Error parsing Gemini response: $e");
        }
      } else {
        setState(() {
          _responseText = "ไม่สามารถวิเคราะห์ภาพได้ หรือไม่พบข้อมูลในคำตอบ";
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _responseText = "เกิดข้อผิดพลาดในการวิเคราะห์: $e";
        _isAnalyzing = false;
      });
    }
  }

  // ฟังก์ชันอัปโหลดภาพไปยัง Firebase Storage
  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imagesRef = storageRef.child('food_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imagesRef.putFile(imageFile);
      final imageUrl = await imagesRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  // ฟังก์ชันบันทึกข้อมูลลงใน Food Diary
  Future<void> _saveToFoodDiary(Map<String, dynamic> foodData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    User? user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล")));
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    DocumentReference dateDocRef = firestore.collection('users').doc(user.uid).collection('food_diary').doc(formattedDate);

    try {
      await dateDocRef.set({
        'entries': FieldValue.arrayUnion([foodData]),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกลง Food Diary เรียบร้อยแล้ว!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e')));
    }
  }

  // ฟังก์ชันแสดง Dialog สำหรับเลือกวันที่และมื้ออาหาร
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
                          _showFoodDiaryDialog();  // Re-show dialog after date selection
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
                            _saveToFoodDiary({
                              'calories': calories,
                              'food': foodName,
                              'image': imageUrl,
                              'meal': selectedMeal,
                              'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate),
                            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _isAnalyzing ? null : _pickImage,
                child: Container(
                  width: 270,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/upload.png',
                      width: 300,
                      height: 330,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_image != null)
                Column(
                  children: [
                    if (_isAnalyzing)
                      Text(
                        'Processing...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Image.file(
                        _image!,
                        height: 150,
                        width: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              if (!_isAnalyzing)
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: Text(
                    _responseText,
                    style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.2),
                  ),
                ),
              SizedBox(height: 30),
              // ปุ่มเพิ่มลง Food Diary ที่กดแล้วจะเปิด alert
              ElevatedButton(
                onPressed: () {
                  _showFoodDiaryDialog();  // เมื่อกดปุ่มจะเปิด dialog สำหรับเลือกวันที่และมื้ออาหาร
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6F6F),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'เพิ่มลง Food Diary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
