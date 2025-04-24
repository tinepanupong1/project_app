import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_app/component/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WeightControlScreen extends StatefulWidget {
  const WeightControlScreen({Key? key}) : super(key: key);

  @override
  _WeightControlScreenState createState() => _WeightControlScreenState();
}

class _WeightControlScreenState extends State<WeightControlScreen> {
  double currentWeight = 0.0;
  double goalWeight = 0.0;
  String goalType = 'Select Occupation';
  double targetDuration = 12;
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController goalWeightController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<FlSpot> weightDataPoints = [];

  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://youtu.be/zPdbf1OdB9E',
      )!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    currentWeightController.dispose();
    goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        currentWeight = (doc['weight'] as num?)?.toDouble() ?? 0.0;
        goalWeight = (doc['goalWeight'] as num?)?.toDouble() ?? 0.0;
        targetDuration = (doc['targetDuration'] as num?)?.toDouble() ?? 12.0;
        goalType = doc['goalType'] ?? 'Select Occupation';
      });
      currentWeightController.text = currentWeight.toString();
      goalWeightController.text = goalWeight.toString();
    }

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weightHistory')
        .orderBy('date')
        .get();
    final pts = <FlSpot>[];
    for (var i = 0; i < snap.docs.length; i++) {
      final w = (snap.docs[i]['weight'] as num).toDouble();
      pts.add(FlSpot(i.toDouble(), w));
    }
    setState(() => weightDataPoints = pts);

    if (currentWeight == goalWeight && goalWeight != 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยินดีด้วย! คุณบรรลุเป้าหมายแล้ว')),
      );
    }
  }

  Future<void> saveCurrentWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newWeight = double.tryParse(currentWeightController.text) ?? 0.0;
    final ts = Timestamp.fromDate(selectedDate);
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weightHistory')
        .where('date', isEqualTo: ts)
        .get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({'weight': newWeight});
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weightHistory')
          .add({'date': ts, 'weight': newWeight});
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'weight': newWeight});

    setState(() => currentWeight = newWeight);
    await fetchUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกน้ำหนักปัจจุบันเรียบร้อย!')),
    );
  }

  Future<void> saveGoalData() async {
    if (goalType == 'รักษาน้ำหนัก') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณายกเลิกเป้าหมายรักษาน้ำหนักก่อน')),
      );
      return;
    }
    final target = double.tryParse(goalWeightController.text) ?? 0.0;
    if ((target - currentWeight).abs() > targetDuration * 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เป้าหมายเกินขีดจำกัดความปลอดภัย')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'goalWeight': target,
        'targetDuration': targetDuration,
        'goalType': goalType,
      });
      setState(() => goalWeight = target);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกเป้าหมายเรียบร้อย!')),
      );
    }
  }

  Future<void> cancelGoal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'goalType': null});
    setState(() => goalType = 'Select Occupation');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ยกเลิกเป้าหมายเรียบร้อย')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ข้อมูลเพิ่มเติม'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ระบบได้กำหนดการลดน้ำหนัก\nและเพิ่มน้ำหนักได้สัปดาห์ละ 0.5 กิโลกรัม สูงสุด 12 สัปดาห์',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _launchURL(
                        'https://www.thaihealth.or.th/ลดน้ำหนักอย่างไรให้ปลอ/'),
                    child: const Text('ลดน้ำหนัก (อ่าน)'),
                  ),
                  TextButton(
                    onPressed: () => _launchURL(
                        'https://www.phyathai.com/th/article/3236-ไม่จำเป็นต้องอด?srsltid=AfmBOopF44vIYHY1GoVpdfPIhOHzMjOTmFANf1rKUzjRllUcGVXvXpLH'),
                    child: const Text('บทความที่สอง'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController,
                  showVideoProgressIndicator: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        title:
            const Text('ควบคุมน้ำหนัก', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // น้ำหนักปัจจุบัน -> เป้าหมาย
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currentWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 24)),
                const Icon(Icons.arrow_forward),
                Text('${goalWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 20),
            // กราฟน้ำหนัก
            Container(
              height: 180,
              color: Colors.orange.shade50,
              child: weightDataPoints.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: weightDataPoints,
                          isCurved: true,
                          colors: [Colors.orange],
                          barWidth: 3,
                          belowBarData: BarAreaData(
                              show: true,
                              colors: [Colors.orange.withOpacity(0.3)]),
                        ),
                      ],
                    )),
            ),
            const SizedBox(height: 20),
            // ฟอร์มบันทึกน้ำหนักวันนี้
            TextField(
              controller: currentWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'บันทึกน้ำหนักวันนี้',
                suffixText: 'กก.',
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('เลือกวันที่', style: TextStyle(color: backgroundPink)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                const SizedBox(width: 10),
                Text('${selectedDate.toLocal()}'.split(' ')[0]),
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
