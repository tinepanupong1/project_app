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
  double currentWeight = 0.0; // น้ำหนักปัจจุบันที่ดึงจาก Firebase
  double goalWeight = 0.0; // น้ำหนักเป้าหมายที่ตั้งไว้
  String goalType = 'Select Occupation'; // ประเภทเป้าหมาย (ลดน้ำหนัก/เพิ่มน้ำหนัก)
  double targetDuration = 12; // ระยะเวลาเริ่มต้น (สัปดาห์) ที่เลือกจาก Slider
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController goalWeightController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // วันที่เลือกสำหรับบันทึกน้ำหนัก
  List<FlSpot> weightDataPoints = []; // จุดข้อมูลสำหรับกราฟน้ำหนัก

  @override
  void initState() {
    super.initState();
    fetchUserData(); // ดึงข้อมูลจาก Firebase เมื่อเริ่มใช้งาน
  }

Future<void> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    var userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      currentWeight = (userDocument['weight'] as num).toDouble();  // ใช้ as num ก่อนแปลงเป็น double
      goalWeight = (userDocument['goalWeight'] as num?)?.toDouble() ?? 0.0;  // ใช้ as num ก่อนแปลงเป็น double พร้อม fallback
      targetDuration = (userDocument['targetDuration'] as num?)?.toDouble() ?? 12.0;
      goalType = userDocument['goalType'] ?? 'Select Occupation';
    });

    currentWeightController.text = currentWeight.toString();
    goalWeightController.text = goalWeight.toString();

    // ดึงข้อมูลประวัติกราฟน้ำหนัก
    var weightHistorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weightHistory')
        .orderBy('date', descending: false)
        .get();

    List<FlSpot> newDataPoints = [];
    int index = 0;

    for (var doc in weightHistorySnapshot.docs) {
      double weight = (doc['weight'] as num).toDouble(); // ใช้ as num ก่อนแปลงเป็น double
      newDataPoints.add(FlSpot(index.toDouble(), weight));
      index++;
    }

    setState(() {
      weightDataPoints = newDataPoints;
    });

    // ตรวจสอบว่าถึงเป้าหมายหรือยัง
    if (currentWeight == goalWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ยินดีด้วย! คุณบรรลุเป้าหมายแล้ว")),
      );
    }
  }
}


  Future<void> saveCurrentWeight() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      double newWeight = double.tryParse(currentWeightController.text) ?? 0.0;

      // ค้นหาว่ามีข้อมูลในวันที่ที่เลือกแล้วหรือไม่
      var existingData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weightHistory')
          .where('date', isEqualTo: Timestamp.fromDate(selectedDate))
          .get();

      if (existingData.docs.isNotEmpty) {
        // อัปเดตข้อมูลหากมีข้อมูลของวันที่เลือกแล้ว
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weightHistory')
            .doc(existingData.docs.first.id)
            .update({
          'weight': newWeight,
        });
      } else {
        // เพิ่มข้อมูลใหม่หากยังไม่มีข้อมูลของวันที่เลือก
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weightHistory')
            .add({
          'weight': newWeight,
          'date': Timestamp.fromDate(selectedDate),
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'weight': newWeight,
      });

      setState(() {
        currentWeight = newWeight;
        fetchUserData(); // อัปเดตกราฟหลังจากบันทึก
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("บันทึกน้ำหนักปัจจุบันเรียบร้อย!")),
      );
    }
  }

  Future<void> saveGoalData() async {
    double targetWeight = double.tryParse(goalWeightController.text) ?? 0.0;
    double weightDiff = (targetWeight - currentWeight).abs();
    double maxAllowedChange = targetDuration * 0.5;

    // แจ้งเตือนหากเป้าหมายเกินขีดจำกัดความปลอดภัย
    if (weightDiff > maxAllowedChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เป้าหมายเกินขีดจำกัดความปลอดภัย กรุณาปรับเป้าหมาย")),
      );
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
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
      backgroundColor: Color(0xFFFFF7EB), // สีพื้นหลัง
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
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${currentWeight.toStringAsFixed(1)} kg",
                    style: TextStyle(fontSize: 24, color: Colors.black)),
                Icon(Icons.arrow_forward, color: Colors.black),
                Text("${goalWeight.toStringAsFixed(1)} kg",
                    style: TextStyle(fontSize: 24, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              color: Colors.orange.shade50,
              child: weightDataPoints.isEmpty
                  ? Center(
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
                                show: true, colors: [Colors.orange.withOpacity(0.3)]),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: currentWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'บันทึกน้ำหนักวันนี้',
                suffixText: 'กก.',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: backgroundHead, width: 1.5), // ขอบสีเทาเมื่อไม่ได้ focus
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveCurrentWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundGreen,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 182, 223, 235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: goalType,
                    items: <String>[
                      'Select Occupation',
                      'ลดน้ำหนัก',
                      'เพิ่มน้ำหนัก'
                    ].map((String value) {
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
                        borderSide: BorderSide(
                            color: backgroundHead, width: 1.5),
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
                        borderSide: BorderSide(
                            color: backgroundHead, width: 1.5),
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
                      backgroundColor: backgroundYellow,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'บันทึกเป้าหมาย',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
