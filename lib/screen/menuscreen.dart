import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final String foodName;
  final num calories;

  MenuScreen({required this.foodName, required this.calories});

  @override
  Widget build(BuildContext context) {
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
            Navigator.pop(context); // ปิดหน้าจอ
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ปรับขนาดของภาพให้ใหญ่ขึ้น
            Image.asset(
              'assets/images/dish.png',
              height: 200, // เพิ่มขนาดของภาพ
              width: 200,  // กำหนดขนาดความกว้าง
              fit: BoxFit.cover, // ให้ภาพขยายตามขนาดที่กำหนด
            ),
            const SizedBox(height: 20),
            Text(
              foodName,
              style: const TextStyle(
                fontSize: 24, // เพิ่มขนาดฟอนต์
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${calories.toString()} แคลอรี่',
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
                      onPressed: () {},
                    ),
                    const Text(
                      '1',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
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
                          height: 100, // ขยายขนาดของภาพวิ่ง
                        ),
                        const SizedBox(height: 5),
                        const Text('วิ่ง 10 นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/bike.png',
                          height: 100, // ขยายขนาดของภาพปั่นจักรยาน
                        ),
                        const SizedBox(height: 5),
                        const Text('ปั่นจักรยาน 20 นาที'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/swim.png',
                          height: 100, // ขยายขนาดของภาพว่ายน้ำ
                        ),
                        const SizedBox(height: 5),
                        const Text('ว่ายน้ำ 5 นาที'),
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
