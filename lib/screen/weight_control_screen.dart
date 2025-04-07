import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_app/component/constant.dart';

class WeightControlScreen extends StatefulWidget {
  @override
  _WeightControlScreenState createState() => _WeightControlScreenState();
}

class _WeightControlScreenState extends State<WeightControlScreen> {
  double currentWeight = 0.0; // น้ำหนักปัจจุบันจาก Firebase
  double goalWeight = 0.0;    // น้ำหนักเป้าหมายที่ตั้งไว้
  String goalType = 'Select Occupation'; // fallback เมื่อไม่มีการตั้งค่า
  double targetDuration = 12; // ระยะเวลา (สัปดาห์)
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController goalWeightController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // วันที่สำหรับบันทึกน้ำหนัก
  List<FlSpot> weightDataPoints = [];     // จุดข้อมูลสำหรับกราฟน้ำหนัก

  @override
  void initState() {
    super.initState();
    fetchUserData(); // ดึงข้อมูลจาก Firebase เมื่อเริ่มใช้งาน
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDocument.exists) {
      setState(() {
        currentWeight = (userDocument['weight'] as num?)?.toDouble() ?? 0.0;
        goalWeight = (userDocument['goalWeight'] as num?)?.toDouble() ?? 0.0;
        targetDuration = (userDocument['targetDuration'] as num?)?.toDouble() ?? 12.0;
        // ถ้าใน Firebase ไม่มี goalType ให้ fallback เป็น "Select Occupation"
        goalType = userDocument['goalType'] ?? 'Select Occupation';
      });
      currentWeightController.text = currentWeight.toString();
      goalWeightController.text = goalWeight.toString();
    }

    var weightHistorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weightHistory')
        .orderBy('date', descending: false)
        .get();

    List<FlSpot> newDataPoints = [];
    int index = 0;
    for (var doc in weightHistorySnapshot.docs) {
      double weight = (doc['weight'] as num).toDouble();
      newDataPoints.add(FlSpot(index.toDouble(), weight));
      index++;
    }
    setState(() {
      weightDataPoints = newDataPoints;
    });

    // แจ้งเตือนหากน้ำหนักปัจจุบันเท่ากับเป้าหมาย (และเป้าหมายถูกตั้งไว้)
    if (currentWeight == goalWeight && goalWeight != 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ยินดีด้วย! คุณบรรลุเป้าหมายแล้ว")),
      );
    }
  }

  Future<void> saveCurrentWeight() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double newWeight = double.tryParse(currentWeightController.text) ?? 0.0;
    var existingData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weightHistory')
        .where('date', isEqualTo: Timestamp.fromDate(selectedDate))
        .get();

    if (existingData.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weightHistory')
          .doc(existingData.docs.first.id)
          .update({'weight': newWeight});
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weightHistory')
          .add({
        'weight': newWeight,
        'date': Timestamp.fromDate(selectedDate),
      });
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'weight': newWeight,
    });
    setState(() {
      currentWeight = newWeight;
      fetchUserData();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกน้ำหนักปัจจุบันเรียบร้อย!")),
    );
  }

  Future<void> saveGoalData() async {
    // หาก goalType เป็น "รักษาน้ำหนัก" ให้แจ้งเตือนไม่ให้แก้ไขเป้าหมาย
    if (goalType == 'รักษาน้ำหนัก') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณายกเลิกเป้าหมายรักษาน้ำหนักก่อน")),
      );
      return;
    }
    double targetWeight = double.tryParse(goalWeightController.text) ?? 0.0;
    double weightDiff = (targetWeight - currentWeight).abs();
    double maxAllowedChange = targetDuration * 0.5;

    if (weightDiff > maxAllowedChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("เป้าหมายเกินขีดจำกัดความปลอดภัย กรุณาปรับเป้าหมาย")),
      );
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'goalWeight': targetWeight,
          'targetDuration': targetDuration,
          'goalType': goalType,
        });
        setState(() {
          goalWeight = targetWeight;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("บันทึกเป้าหมายเรียบร้อย!")),
        );
      }
    }
  }

  Future<void> cancelGoal() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'goalType': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ยกเลิกเป้าหมายเรียบร้อย")),
      );
      setState(() {
        goalType = 'Select Occupation';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7EB),
      appBar: AppBar(
        title: const Text('ควบคุมน้ำหนัก', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // แสดงน้ำหนักปัจจุบันกับเป้าหมาย
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${currentWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(fontSize: 24, color: Colors.black)),
                const Icon(Icons.arrow_forward, color: Colors.black),
                Text("${goalWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(fontSize: 24, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 10),
            // กราฟน้ำหนัก
            Container(
              height: 180,
              color: Colors.orange.shade50,
              child: weightDataPoints.isEmpty
                  ? const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: weightDataPoints,
                            isCurved: true,
                            colors: [Colors.orange],
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              colors: [Colors.orange.withOpacity(0.3)],
                            ),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // TextField สำหรับบันทึกน้ำหนักวันนี้
            TextField(
              controller: currentWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'บันทึกน้ำหนักวันนี้',
                suffixText: 'กก.',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: backgroundHead, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Row สำหรับเลือกวันที่
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    "เลือกวันที่",
                    style: TextStyle(color: backgroundPink),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text("${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            // ปุ่มบันทึกน้ำหนักวันนี้
            ElevatedButton(
              onPressed: saveCurrentWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonSave,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('บันทึก',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 20),
            // กล่องตั้งเป้าหมายและตั้งค่าเป้าหมาย
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 182, 223, 235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // ถ้า goalType เป็น "รักษาน้ำหนัก" ให้แสดงข้อความและปุ่มยกเลิก
                  // ถ้าเป็น "ลดน้ำหนัก" หรือ "เพิ่มน้ำหนัก" ให้แสดง Dropdown, TextField, Slider และปุ่มบันทึกเป้าหมาย
                  goalType == "รักษาน้ำหนัก"
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'เป้าหมายของคุณ: รักษาน้ำหนัก',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: cancelGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ยกเลิกเป้าหมาย',
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: (goalType == 'ลดน้ำหนัก' ||
                                      goalType == 'เพิ่มน้ำหนัก')
                                  ? goalType
                                  : null,
                              hint: const Text('Select Occupation'),
                              items: ['ลดน้ำหนัก', 'เพิ่มน้ำหนัก']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  goalType = newValue!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'เป้าหมาย',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: backgroundHead, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: goalWeightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'น้ำหนักที่ต้องการ',
                                suffixText: 'กก.',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: backgroundHead, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  goalWeight = double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ระยะเวลา (สัปดาห์): ${targetDuration.toInt()}"),
                                Slider(
                                  value: targetDuration,
                                  min: 1,
                                  max: 12,
                                  divisions: 11,
                                  label: targetDuration.toInt().toString(),
                                  activeColor: const Color.fromARGB(255, 15, 70, 116),
                                  inactiveColor: Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      targetDuration = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: saveGoalData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonSave,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'บันทึกเป้าหมาย',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: cancelGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ยกเลิกเป้าหมาย',
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            )
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
