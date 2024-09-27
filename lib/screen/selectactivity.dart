import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/screen/loginscreen.dart'; // import หน้าจอ LoginScreen ของคุณ

class SelectActivityScreen extends StatefulWidget {
  @override
  _SelectActivityScreenState createState() => _SelectActivityScreenState();
}

class _SelectActivityScreenState extends State<SelectActivityScreen> {
  String _selectedActivity = ''; // เก็บกิจกรรมที่เลือก
  double _activityFactor = 1.2; // ค่าตัวแปรเริ่มต้น

  void _selectActivity(String activity, double factor) {
    setState(() {
      _selectedActivity = activity;
      _activityFactor = factor; // ตั้งค่าค่าตัวแปรกิจกรรมตามที่เลือก
    });
  }

  Future<void> saveActivityToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'activity': _selectedActivity, // บันทึกกิจกรรมที่เลือก
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ทำให้ทุกอย่างอยู่ตรงกลางในแนวตั้ง
              crossAxisAlignment: CrossAxisAlignment.center, // ทำให้ทุกอย่างอยู่ตรงกลางในแนวนอน
              children: [
                const SizedBox(height: 20),
                const Text(
                  'กิจกรรมที่ทำทุกวัน',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/food5.png',
                  height: 220,
                ),
                const SizedBox(height: 5), // ลดระยะห่างระหว่างภาพและกล่องกิจกรรม
                _buildActivityButton('นั่งทำงานอยู่กับที่และไม่ได้ออกกำลังกายเลย', 1.2),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาเล็กน้อยประมาณอาทิตย์ละ 1-3 วัน', 1.375),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาปานกลางประมาณอาทิตย์ละ 3-5 วัน', 1.55),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาอย่างหนักประมาณอาทิตย์ละ 6-7 วัน', 1.725),
                _buildActivityButton('ออกกำลังกายหรือเล่นที่กีฬาอย่างหนักมากทุกวันเช้า และเย็น', 1.9),
                const SizedBox(height: 10),
                Center( // เพิ่ม Center widget รอบ ๆ ปุ่มสีแดง
                  child: ElevatedButton(
                    onPressed: () {
                      saveActivityToFirestore(); // บันทึกกิจกรรมที่เลือกลงใน Firestore

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('กิจกรรมที่คุณเลือกคือ:'),
                            content: Text(
                              _selectedActivity,
                              style: TextStyle(fontSize: 18),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // ปิด Dialog
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()), 
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text('ตกลง'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton(String text, double factor) {
    bool isSelected = _selectedActivity == text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 280, // กำหนดความกว้างคงที่ให้กับปุ่ม
        height: 60, // กำหนดความสูงคงที่ให้กับปุ่ม
        child: ElevatedButton(
          onPressed: () => _selectActivity(text, factor),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Color.fromARGB(255, 42, 80, 90)
                : const Color.fromRGBO(134, 192, 207, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft, // ทำให้ข้อความชิดซ้าย
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.left, // ทำให้ข้อความชิดซ้าย
            ),
          ),
        ),
      ),
    );
  }
}
