import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Waterscreen extends StatefulWidget {
  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<Waterscreen> {
  double currentWaterIntake = 0.0; // ปริมาณน้ำที่ดื่มในปัจจุบัน
  double goalWaterIntake = 0.0; // เป้าหมายปริมาณน้ำที่ต้องดื่ม
  double userWeight = 0.0; // น้ำหนักของผู้ใช้
  List<String> waterHistory = []; // ประวัติการดื่มน้ำ
  final TextEditingController waterAmountController = TextEditingController(text: '200'); // ค่ามิลลิลิตรที่จะเพิ่มหรือลด

  @override
  void initState() {
    super.initState();
    fetchUserData(); // ดึงข้อมูลผู้ใช้จาก Firebase
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ดึงข้อมูลน้ำหนักของผู้ใช้จาก Firebase Firestore
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userWeight = userDocument['weight']; // น้ำหนักจาก Firebase
        goalWaterIntake = userWeight * 2.2 * 30 / 2; // คำนวณปริมาณน้ำที่ควรดื่มต่อวัน
      });

      // ดึงข้อมูลการดื่มน้ำล่าสุด
      var intakeData = userDocument['currentWaterIntake'] ?? 0.0;
      var historyData = List<String>.from(userDocument['waterHistory'] ?? []);
      setState(() {
        currentWaterIntake = intakeData;
        waterHistory = historyData;
      });
    }
  }

  Future<void> _saveWaterIntakeToFirestore(double amount) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // เพิ่มประวัติการดื่มน้ำใน Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'currentWaterIntake': currentWaterIntake,
        'waterHistory': waterHistory,
      });
    }
  }

  void _updateWaterIntake(double amount) {
    setState(() {
      // ถ้า currentWaterIntake เป็น 0 และมีการลบ (amount < 0) จะไม่ให้ทำการลด
      if (currentWaterIntake == 0 && amount < 0) {
        return; // ไม่ทำอะไรเลยถ้าปริมาณน้ำเป็น 0 แล้วพยายามลบ
      }

      double newIntake = currentWaterIntake + amount;
      currentWaterIntake = newIntake.clamp(0, goalWaterIntake); // จำกัดไม่ให้เกินเป้าหมาย
      String timeEntry = "${DateTime.now().hour}:${DateTime.now().minute} - ${amount.toInt()} ml";
      waterHistory.insert(0, timeEntry);
    });

    // บันทึกข้อมูลการดื่มน้ำลงใน Firestore
    _saveWaterIntakeToFirestore(amount);
  }

  @override
  Widget build(BuildContext context) {
    double progress = (goalWaterIntake > 0) ? currentWaterIntake / goalWaterIntake : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E6),
      appBar: AppBar(
        title: const Text("AquaTrack",),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'น้ำหนักของคุณ: ${userWeight.toStringAsFixed(1)} กิโลกรัม', // แสดงน้ำหนักจาก Firebase
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              'ควรดื่มน้ำประมาณ: ${goalWaterIntake.toInt()} มล.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.blue[100],
                    color: Colors.blueAccent,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentWaterIntake.toInt()} / ${goalWaterIntake.toInt()} ml',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: waterAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ปริมาณน้ำ (มล.)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(waterAmountController.text) ?? 0;
                    _updateWaterIntake(-amount); // ลดตามค่าที่กรอก
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: const Icon(Icons.remove, size: 30, color: Colors.redAccent),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(waterAmountController.text) ?? 0;
                    _updateWaterIntake(amount); // เพิ่มตามค่าที่กรอก
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: const Icon(Icons.add, size: 30, color: Colors.blueAccent),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 176, 180),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ประวัติการดื่มน้ำ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // แสดงรายการประวัติการดื่มน้ำ
                  ...waterHistory.map((record) => ListTile(
                        leading: const Icon(Icons.local_drink, color: Colors.blueAccent),
                        title: Text(record),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
