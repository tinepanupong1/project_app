import 'package:flutter/material.dart';
import 'package:project_app/screen/selectactivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectInfoScreen extends StatefulWidget {
  @override
  _SelectInfoScreenState createState() => _SelectInfoScreenState();
}

class _SelectInfoScreenState extends State<SelectInfoScreen> {
  String _selectedGender = 'Select Gender';
  String _selectedDisease = 'Select Disease';

  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                const CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/food4.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Welcome...',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jua',
                    color: Color.fromRGBO(42, 80, 90, 1),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoSection(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final String gender = _selectedGender;
                    final double weight = double.parse(weightController.text);
                    final double height = double.parse(heightController.text);
                    final int age = int.parse(ageController.text);
                    final String disease = _selectedDisease;
                    final String allergies = allergyController.text;

                    // คำนวณ BMR
                    final double bmr = calculateBMR(gender, weight, height, age, disease);

                    // แสดงค่า BMR ผ่าน AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ค่า BMR'),
                          content: Text('ค่า BMR ของคุณคือ: ${bmr.toStringAsFixed(2)} กิโลแคลอรี/วัน'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // ปิด Dialog
                                // บันทึกข้อมูลผู้ใช้
                                saveUserData(gender, ageController.text, weightController.text, heightController.text, disease, allergies);
                                // ไปยังหน้าจอถัดไปพร้อมกับส่งค่า BMR
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SelectActivityScreen(bmr: bmr)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 197, 66, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เพศ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildDropdownButton(_selectedGender, (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          }, ['Select Gender', 'ชาย', 'หญิง']),
          const SizedBox(height: 10),
          _buildTextField(ageController, 'อายุ'),
          const SizedBox(height: 10),
          _buildTextField(weightController, 'น้ำหนัก (กก.)'),
          const SizedBox(height: 10),
          _buildTextField(heightController, 'ส่วนสูง (ซม.)'),
          const SizedBox(height: 10),
          const Text(
            'โรคที่เป็น',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildDropdownButton(_selectedDisease, (String? newValue) {
            setState(() {
              _selectedDisease = newValue!;
            });
          }, ['Select Disease', 'โรคอ้วน', 'โรคไต', 'โรคความดันโลหิตสูง', 'ไม่เป็นโรค']),
          const SizedBox(height: 10),
          _buildTextField(allergyController, 'อาหารที่แพ้'),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String value, ValueChanged<String?> onChanged, List<String> items) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: labelText,
          ),
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  double calculateBMR(String gender, double weight, double height, int age, String disease) {
    double bmr = 0.0;

    if (disease == 'โรคอ้วน') {
      if (gender == 'ชาย') {
        bmr = (66 + (13.7 * weight) + (5 * height) - (6.8 * age)) - 500;
      } else {
        bmr = (665 + (9.6 * weight) + (1.8 * height) - (4.7 * age)) - 500;
      }
    } else if (disease == 'โรคไต') {
      // สมมติว่าอายุต่ำกว่า 60 ปีสำหรับการคำนวณ
      if (age < 60) {
        bmr = 35 * weight;
      } else {
        bmr = 30 * weight;
      }
    } else if (disease == 'โรคความดันโลหิตสูง') {
      if (gender == 'ชาย') {
        bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
      } else {
        bmr = 665 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
      }
    } else if (disease == 'ไม่เป็นโรค') {
      if (gender == 'ชาย') {
        bmr = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
    } else {
        bmr = 665 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
  }
  
    return bmr;
  }

  Future<void> saveUserData(String gender, String age, String weight, String height, String disease, String allergies) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save to SharedPreferences
    await prefs.setString('gender', gender);
    await prefs.setString('age', age);
    await prefs.setString('weight', weight);
    await prefs.setString('height', height);
    await prefs.setString('disease', disease);
    await prefs.setString('allergies', allergies);

    // Save to Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'gender': gender,
        'age': int.parse(age),
        'weight': double.parse(weight),
        'height': double.parse(height),
        'disease': disease,
        'allergies': allergies,
      });
    }
  }
}
