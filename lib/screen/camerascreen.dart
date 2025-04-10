import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _responseText = 'กรุณาอัปโหลดรูปภาพอาหาร';  // ข้อความเริ่มต้น
  bool _isAnalyzing = false;

  // ฟังก์ชันเลือกภาพ
  Future<void> _pickImage() async {
    setState(() {
      _responseText = 'Process...';  // เปลี่ยนเป็น "Process..." ทันทีที่เริ่มการอัปโหลด
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

  // ฟังก์ชันการวิเคราะห์อาหาร
  Future<void> _analyzeFoodWithGemini(File imageFile) async {
    final String apiKey = 'AIzaSyB4rI-ch_vqO4dAlwT1X4sLRI2jvaJoByU'; // แทนที่ด้วย API Key ของคุณ
    final GenerativeModel model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey); // ใช้โมเดลที่รองรับ

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = 'image/jpeg'; // หรือ 'image/png' ตามประเภทไฟล์ภาพของคุณ

      // สร้าง Content ให้ถูกต้องตามพารามิเตอร์ที่จำเป็น
      final content = [
        Content(
          'user', // ตั้งค่า role เป็น 'user'
          [
            TextPart('ช่วยวิเคราะห์อาหารในรูปภาพนี้ โดยเขียนเป็นไม่ต้องเขียนข้อมูลอื่น ชื่อเมนูอาหาร: ตามด้วยชื่ออาหาร และบรรทัดต่อไปจะเป็นส่วนประกอบหลักเป็นข้อๆโดยให้ มีชื่อวัตถุดิบ พร้อมกับ จำนวนปริมาณหน่วยของวัตถุดิบนั้นๆ แล้วสุดท้ายข้างล่างสุดจะสรุปแคลอรี่ทั้งหมดของอาหาร'),
            DataPart('image/jpeg', bytes),
          ],
        ),
      ];

      final response = await model.generateContent(content);

      if (response.text != null) {
        setState(() {
          _responseText = response.text!; // อัพเดตข้อความที่ได้จากการวิเคราะห์
          _isAnalyzing = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,  // เพิ่มการจัดตำแหน่งให้ตรงกลาง
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ใช้รูป upload.png แทนสีแดง
            GestureDetector(
              onTap: _isAnalyzing ? null : _pickImage, // ปิดการคลิกตอนที่กำลังวิเคราะห์
              child: Container(
                width: 270, // ขนาดตามต้นฉบับ
                height: 300, // ขนาดตามต้นฉบับ
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/upload.png', // ใช้รูป upload.png จาก assets
                    width: 300, // ขนาดของรูปใหญ่
                    height: 330, // ขนาดของรูปใหญ่
                    fit: BoxFit.contain, // ปรับให้รูปไม่ตัด
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // แสดงข้อความ "Process..." ข้างบนภาพ
            if (_image != null)
              Column(
                children: [
                  if (_isAnalyzing)
                    Text(
                      'Process...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  SizedBox(height: 10), // เพิ่มช่องว่างระหว่างข้อความกับภาพ
                  Image.file(
                    _image!,
                    height: 150,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            SizedBox(height: 20),
            // ถ้าอยู่ในระหว่างการวิเคราะห์จะแสดงข้อความ "Process..." หรือ "กำลังเตรียมวิเคราะห์"
            if (!_isAnalyzing)
              Text(
                _responseText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.2, // เพิ่มระยะห่างระหว่างบรรทัด
                ),
              ),
            SizedBox(height: 30), // เพิ่มพื้นที่ให้ปุ่มด้านล่าง
            // เพิ่มปุ่ม "บันทึกลง Food Diary"
            ElevatedButton(
              onPressed: () {
                // ฟังก์ชันจะอยู่ในขั้นตอนถัดไป (ไม่ทำอะไรตอนนี้)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6F6F), // สีพื้นหลังของปุ่ม
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'บันทึกลง Food Diary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
