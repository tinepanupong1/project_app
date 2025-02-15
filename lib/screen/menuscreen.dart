import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late final String cachedImageUrl;
  List<Map<String, dynamic>> foodDiaryList = [];
  DateTime selectedDate = DateTime.now();
  String selectedMeal = 'เช้า';

  @override
  void initState() {
    super.initState();
    cachedImageUrl = widget.imageUrl;
  }

  void _showFoodDiaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8), // เปลี่ยนเป็นโปร่งใสสีขาวแบบภาพที่ 1
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Center(
                  child: Text(
                    'บันทึกลง Food Diary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลือกวันที่',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                          Navigator.pop(context);
                          _showFoodDiaryDialog();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 1.5)),
                        ),
                        child: Text(
                          DateFormat('dd / MM / yyyy').format(selectedDate),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'เลือกมื้ออาหาร',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedMeal,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: ['เช้า', 'กลางวัน', 'เย็น', 'ของว่าง']
                          .map((meal) => DropdownMenuItem(
                                value: meal,
                                child: Text(meal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMeal = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ยกเลิก',
                              style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveToFoodDiary(selectedDate, selectedMeal);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _saveToFoodDiary(DateTime date, String meal) {
    setState(() {
      foodDiaryList.add({
        'date': '${date.day}/${date.month}/${date.year}',
        'meal': meal,
        'food': widget.foodName,
        'calories': widget.calories * plateCount,
        'quantity': plateCount,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึก ${widget.foodName} ใน $meal วันที่ ${date.day}/${date.month}/${date.year} แล้ว'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
            // ✅ ปรับให้โหลดรูปแค่ครั้งเดียว
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  cachedImageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 200, color: Colors.grey);
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
              onPressed: _showFoodDiaryDialog,
              child: const Text('บันทึกลง Food Diary'),
            ),
          ],
        ),
      ),
    );
  }
}