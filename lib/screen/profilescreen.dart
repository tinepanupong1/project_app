//profilescreen
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_app/component/constant.dart';
import 'package:project_app/screen/homescreen.dart';

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
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
      setState(() {}); // Update UI after fetching data
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Jua',
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A505A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', nameController),
                _buildTextField('Gender', genderController),
                _buildTextField('Age', ageController),
                _buildTextField('Weight', weightController),
                _buildTextField('Height', heightController),
                _buildDiseaseDropdown(),
                _buildTextField('Allergy', allergyController),
                _buildActivityDropdown(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                // Update data in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                  'name': nameController.text,
                  'gender': genderController.text,
                  'age': int.tryParse(ageController.text) ?? 0,
                  'weight': double.tryParse(weightController.text) ?? 0.0,
                  'height': double.tryParse(heightController.text) ?? 0.0,
                  'disease': diseaseController.text,
                  'allergies': allergyController.text,
                  'activity': activityController.text,
                });

                // Update UI immediately
                setState(() {});

                // Close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDiseaseDropdown() {
    List<String> diseases = [
      'โรคอ้วน',
      'โรคไต',
      'โรคความดันโลหิตสูง',
      'ไม่เป็นโรค',
    ];

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Disease'),
      value: diseaseController.text.isEmpty ? null : diseaseController.text,
      onChanged: (String? newValue) {
        setState(() {
          diseaseController.text = newValue ?? '';
        });
      },
      isExpanded: true,
      items: diseases.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            overflow: TextOverflow.clip,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityDropdown() {
    List<String> activities = [
      'นั่งทำงานอยู่กับที่และไม่ได้ออกกำลังกายเลย',
      'ออกกำลังกายหรือเล่นกีฬาเล็กน้อยประมาณอาทิตย์ละ 1-3 วัน',
      'ออกกำลังกายหรือเล่นกีฬาปานกลางประมาณอาทิตย์ละ 3-5 วัน',
      'ออกกำลังกายหรือเล่นกีฬาอย่างหนักประมาณอาทิตย์ละ 6-7 วัน',
      'ออกกำลังกายหรือเล่นที่กีฬาอย่างหนักมากทุกวันเช้า และเย็น',
    ];

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Activity'),
      value: activityController.text.isEmpty ? null : activityController.text,
      onChanged: (String? newValue) {
        setState(() {
          activityController.text = newValue ?? '';
        });
      },
      isExpanded: true,
      items: activities.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            overflow: TextOverflow.clip,
          ),
        );
      }).toList(),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF64D98A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}
