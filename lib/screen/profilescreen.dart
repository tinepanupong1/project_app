import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart package

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController diseaseController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();
  final TextEditingController activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      nameController.text = data['name'] ?? 'Unknown';
      genderController.text = data['gender'] ?? 'Select Gender';
      ageController.text = data['age']?.toString() ?? '';
      weightController.text = data['weight']?.toString() ?? '';
      heightController.text = data['height']?.toString() ?? '';
      diseaseController.text = data['disease'] ?? 'Select Disease';
      allergyController.text = data['allergies'] ?? '';
      activityController.text = data['activity'] ?? '';
      setState(() {});
    }
  }

  double calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    if (height > 0) {
      return weight / ((height / 100) * (height / 100));
    }
    return 0.0;
  }

  void _editProfile() {
    // Your edit profile dialog code here
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    double bmi = calculateBMI();

    return Scaffold(
      backgroundColor: const Color(0xFFF6E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2A505A),
        ),
      ),
      body: SingleChildScrollView( // เพิ่ม SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // กราฟสถิติอยู่ด้านบน
            Container(
              height: 200, // กำหนดความสูงของกราฟ
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF64D98A), // สีพื้นหลังของกราฟ
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'ปริมาณแคลอรี่เดือน มกราคม 2567',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: SideTitles(showTitles: true),
                            bottomTitles: SideTitles(showTitles: true),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 1500),
                                FlSpot(1, 1600),
                                FlSpot(2, 1700),
                                FlSpot(3, 1800),
                                FlSpot(4, 1900),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ProfileCard(
              name: nameController.text,
              gender: genderController.text,
              age: int.tryParse(ageController.text) ?? 0,
              weight: double.tryParse(weightController.text) ?? 0.0,
              height: double.tryParse(heightController.text) ?? 0.0,
              disease: diseaseController.text,
              allergy: allergyController.text,
              activity: activityController.text,
              bmi: bmi,
              onEdit: _editProfile,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.arrow_back), // ไอคอนปุ่มย้อนกลับ
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String disease;
  final String allergy;
  final String activity;
  final double bmi;
  final VoidCallback onEdit;

  ProfileCard({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.disease,
    required this.allergy,
    required this.activity,
    required this.bmi,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCC66A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ข้อมูลส่วนตัว',
                style: TextStyle(fontSize: 20, color: Color(0xFF2A505A)),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2A505A)),
                onPressed: onEdit,
              ),
            ],
          ),
          _buildInfoRow('ชื่อ', name),
          _buildInfoRow('เพศ', gender),
          _buildInfoRow('อายุ', '$age'),
          _buildInfoRow('น้ำหนัก', '$weight kg'),
          _buildInfoRow('ส่วนสูง', '$height cm'),
          _buildInfoRow('โรคที่เป็น', disease),
          _buildInfoRow('อาหารแพ้', allergy),
          _buildInfoRow('กิจกรรมที่ทำเป็นประจำ', activity),
          const SizedBox(height: 10),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'BMI: ${bmi.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
