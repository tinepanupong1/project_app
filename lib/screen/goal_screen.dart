import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // ใช้สำหรับแสดงกราฟ

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController weightGoalController = TextEditingController();
  String? selectedGoal; // เก็บเป้าหมายที่เลือก
  DateTime? selectedDate; // เก็บวันที่เลือกสำหรับระยะเวลา

  // รายการของเป้าหมายให้เลือก
  final List<String> goals = [
    'ลดน้ำหนัก',
    'เพิ่มน้ำหนัก',
    'รักษาน้ำหนัก',
  ];

  // ฟังก์ชันสำหรับเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Goal'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2A505A),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // แสดงกราฟความก้าวหน้า
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF64D98A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'บันทึกความก้าวหน้า',
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
                                FlSpot(0, 70),
                                FlSpot(1, 69),
                                FlSpot(2, 68),
                                FlSpot(3, 67),
                                FlSpot(4, 66),
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
            // การเลือกเป้าหมาย
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'เป้าหมาย'),
              value: selectedGoal,
              onChanged: (newValue) {
                setState(() {
                  selectedGoal = newValue;
                });
              },
              items: goals.map((goal) {
                return DropdownMenuItem<String>(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // กำหนดน้ำหนักที่ต้องการ
            TextField(
              controller: weightGoalController,
              decoration: const InputDecoration(
                labelText: 'น้ำหนักที่ต้องการ (กก.)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // การเลือกระยะเวลา
            GestureDetector(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'ระยะเวลาสิ้นสุด ',
                ),
                child: Text(selectedDate != null
                    ? '${selectedDate?.toLocal()}'.split(' ')[0]
                    : 'เลือกวันที่'),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่มบันทึกเป้าหมาย
            ElevatedButton(
              onPressed: () {
                // เพิ่มโค้ดบันทึกข้อมูลเป้าหมาย
              },
              child: const Text('บันทึกเป้าหมาย'),
            ),
            const SizedBox(height: 20),
            // ปุ่มย้อนกลับ
            FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.arrow_back),
            ),
          ],
        ),
      ),
    );
  }
}
