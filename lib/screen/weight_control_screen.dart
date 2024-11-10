import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightControlScreen extends StatefulWidget {
  @override
  _WeightControlScreenState createState() => _WeightControlScreenState();
}

class _WeightControlScreenState extends State<WeightControlScreen> {
  double currentWeight = 0.0; // น้ำหนักปัจจุบันจาก Firebase
  double goalWeight = 0.0; // น้ำหนักเป้าหมาย
  double weightChange = 0.0; // การเปลี่ยนแปลงน้ำหนักที่ต้องการ
  double targetDuration = 1.0; // ระยะเวลาที่ต้องการในการควบคุมน้ำหนัก (สัปดาห์)
  double weeklyWeightChange = 0.5; // การเปลี่ยนแปลงน้ำหนักต่อสัปดาห์ (0.5 กิโลกรัม)
  final TextEditingController goalWeightController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    fetchUserData(); // ดึงข้อมูลน้ำหนักจาก Firebase
  }

  // ฟังก์ชันในการดึงน้ำหนักจาก Firebase
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        currentWeight = userDocument['weight']; // ดึงน้ำหนักปัจจุบันจาก Firebase
      });
    }
  }

  // ฟังก์ชันในการคำนวณน้ำหนักเป้าหมายและระยะเวลา
  void calculateGoalWeight() {
    // คำนวณน้ำหนักเป้าหมายโดยใช้การเพิ่มหรือลดน้ำหนัก 0.5 กิโลกรัมต่อสัปดาห์
    setState(() {
      weightChange = weeklyWeightChange * targetDuration; // คำนวณการเปลี่ยนแปลงน้ำหนัก
      goalWeight = currentWeight + weightChange; // คำนวณน้ำหนักเป้าหมาย
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ควบคุมน้ำหนัก'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงน้ำหนักปัจจุบันจาก Firebase
            Text(
              'น้ำหนักปัจจุบัน: ${currentWeight.toStringAsFixed(1)} กิโลกรัม',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // กรอกน้ำหนักเป้าหมาย
            TextField(
              controller: goalWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'น้ำหนักเป้าหมาย (กิโลกรัม)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  goalWeight = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 20),

            // เลือกระยะเวลาที่จะใช้ในการควบคุมน้ำหนัก (1 สัปดาห์–3 เดือน)
            Row(
              children: [
                const Text('ระยะเวลา (สัปดาห์): ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: targetDuration,
                    min: 1,
                    max: 12, // 12 สัปดาห์ (3 เดือน)
                    divisions: 11,
                    label: targetDuration.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        targetDuration = value;
                      });
                    },
                  ),
                ),
                Text('${targetDuration.round()} สัปดาห์'),
              ],
            ),
            const SizedBox(height: 20),

            // แสดงการเปลี่ยนแปลงน้ำหนัก
            Text(
              'เปลี่ยนแปลงน้ำหนัก: ${weightChange.toStringAsFixed(1)} กิโลกรัม',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ปุ่มคำนวณ
            ElevatedButton(
              onPressed: calculateGoalWeight,
              child: const Text('คำนวณน้ำหนักเป้าหมาย'),
            ),
            const SizedBox(height: 40),

            // แสดงกราฟน้ำหนักเป้าหมาย
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: (goalWeight > currentWeight) ? (weightChange / 10) : 0.0, // คำนวณการเปลี่ยนแปลง
                    strokeWidth: 12,
                    backgroundColor: Colors.blue[100],
                    color: Colors.greenAccent,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'น้ำหนักที่ต้องการ: ${goalWeight.toStringAsFixed(1)} กิโลกรัม',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${((weightChange / targetDuration) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
