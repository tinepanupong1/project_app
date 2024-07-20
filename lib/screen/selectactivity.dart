import 'package:flutter/material.dart';

class SelectActivityScreen extends StatefulWidget {
  @override
  _SelectActivityScreenState createState() => _SelectActivityScreenState();
}

class _SelectActivityScreenState extends State<SelectActivityScreen> {
  String _selectedActivity = '';

  void _selectActivity(String activity) {
    setState(() {
      _selectedActivity = activity;
    });
  }

  Widget _buildActivityButton(String text) {
    bool isSelected = _selectedActivity == text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 280, // กำหนดความกว้างคงที่ให้กับปุ่ม
        height: 60, // กำหนดความสูงคงที่ให้กับปุ่ม
        child: ElevatedButton(
          onPressed: () => _selectActivity(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ?  Color.fromARGB(255, 42, 80, 90) : const Color.fromRGBO(134, 192, 207, 1),
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
                _buildActivityButton('นั่งทำงานอยู่กับที่\nและไม่ได้ออกกำลังกายเลย'),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาเล็กน้อย\nประมาณอาทิตย์ละ 1-3 วัน'),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาปานกลาง\nประมาณอาทิตย์ละ 3-5 วัน'),
                _buildActivityButton('ออกกำลังกายหรือเล่นกีฬาอย่างหนัก\nประมาณอาทิตย์ละ 6-7 วัน'),
                _buildActivityButton('ออกกำลังกายหรือเล่นที่กีฬาอย่างหนักมากทุกวันเช้า และเย็น'),
                const SizedBox(height: 10),
                Center( // เพิ่ม Center widget รอบ ๆ ปุ่มสีแดง
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement your logic here
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
                // Removed the display of selected activity
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SelectActivityScreen(),
  ));
}
