import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final String foodName;
  final num calories;
  final String imageUrl;

  MenuScreen({required this.foodName, required this.calories, required this.imageUrl});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int plateCount = 1;

  @override
  Widget build(BuildContext context) {
    final totalCalories = widget.calories * plateCount;
    final runMinutes = (totalCalories / 10).toStringAsFixed(0);
    final bikeMinutes = (totalCalories / 7).toStringAsFixed(0);
    final swimMinutes = (totalCalories / 13).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(
            fontFamily: 'Jua',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ เพิ่มเงาให้กับขอบรูป
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // ทำให้รูปมีมุมโค้งมน
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // เงาสีดำแบบอ่อน
                    spreadRadius: 2, // การกระจายของเงา
                    blurRadius: 8, // ความเบลอของเงา
                    offset: Offset(0, 4), // ตำแหน่งของเงา (ลงล่าง)
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.imageUrl + "?t=${DateTime.now().millisecondsSinceEpoch}",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 200, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.foodName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$totalCalories แคลอรี่',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (plateCount > 1) {
                          setState(() {
                            plateCount--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$plateCount',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          plateCount++;
                        });
                      },
                    ),
                  ],
                ),
                const Text(
                  'จาน',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  'ปริมาณแคลอรี่เทียบเท่าการออกกำลังกาย',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/run.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('วิ่ง $runMinutes นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/bike.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('ปั่นจักรยาน $bikeMinutes นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/swim.png',
                          height: 100,
                        ),
                        const SizedBox(height: 5),
                        Text('ว่ายน้ำ $swimMinutes นาที'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ฟังก์ชันบันทึกข้อมูลลง Food Diary
              },
              child: const Text('บันทึกลง Food Diary'),
            ),
          ],
        ),
      ),
    );
  }
}
