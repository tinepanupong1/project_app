import 'package:flutter/material.dart';
import 'menuscreen.dart'; // นำเข้า MenuScreen
import 'package:intl/intl.dart';

class FoodDiaryScreen extends StatefulWidget {
  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  int currentIndex = 0;
  final DateTime now = DateTime.now(); // วันเวลาปัจจุบัน
  DateTime selectedDate = DateTime.now(); // เก็บค่าวันที่เลือก

  final List<Map<String, String>> foodDiary = [
    {
      'meal': 'มื้อเที่ยง',
      'food': 'ข้าวไข่เจียว',
      'calories': '650 kcal',
      'image': 'assets/images/fried_rice_egg.png',
    },
    {
      'meal': 'มื้อเย็น',
      'food': 'ข้าวผัดหมู',
      'calories': '550 kcal',
      'image': 'assets/images/fried_rice_pork.png',
    },
  ];

  void nextMeal() {
    setState(() {
      currentIndex = (currentIndex + 1) % foodDiary.length;
    });
  }

  void previousMeal() {
    setState(() {
      currentIndex = (currentIndex - 1 + foodDiary.length) % foodDiary.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMeal = foodDiary[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Food Diary'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.pink),
            onPressed: () {
              // นำทางไปยัง MenuScreen เมื่อกดปุ่ม
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()), // นำทางไปยังหน้าจอ MenuScreen
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: previousMeal,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.pink),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: nextMeal,
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.pink),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade100,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            currentMeal['image']!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentMeal['meal']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentMeal['food']} : ${currentMeal['calories']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'เลือกวันจากปฏิทิน',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomCalendarWidget(
                    now: now,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date; // อัปเดตวันที่เลือก
                      });
                    },
                  ), // ปฏิทินสำหรับเลือกวันที่
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

class CustomCalendarWidget extends StatelessWidget {
  final DateTime now;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  CustomCalendarWidget({
    required this.now,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateFormat formatter = DateFormat('MMM y'); // Format เดือนและปี

  // สร้างรายการวันในเดือนปัจจุบัน
  List<TableRow> buildCalendar() {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    int dayOfWeek = firstDayOfMonth.weekday; // เริ่มต้นของวันในเดือนนี้ (1 = Mon, 7 = Sun)
    List<TableRow> rows = [];

    // สร้างแถวแรกของวันในเดือน
    List<Widget> firstRow = List.generate(7, (index) {
      if (index < dayOfWeek - 1) {
        return const SizedBox(); // ช่องว่างสำหรับวันก่อนวันที่ 1
      } else {
        return buildDayCell(index - dayOfWeek + 2);
      }
    });
    rows.add(TableRow(children: firstRow));

    // สร้างแถวที่เหลือของปฏิทิน
    int day = 8 - dayOfWeek;
    while (day <= daysInMonth) {
      List<Widget> weekRow = List.generate(7, (index) {
        if (day <= daysInMonth) {
          return buildDayCell(day++);
        } else {
          return const SizedBox(); // ช่องว่างสำหรับวันหลังจากสิ้นเดือน
        }
      });
      rows.add(TableRow(children: weekRow));
    }

    return rows;
  }

  // ฟังก์ชันสำหรับสร้างเซลล์วันที่ พร้อมไฮไลต์วันที่ปัจจุบันและวันที่เลือก
  Widget buildDayCell(int day) {
    final DateTime today = DateTime.now();
    final DateTime thisDay = DateTime(now.year, now.month, day);
    final bool isToday = today.day == day && today.month == now.month && today.year == now.year;
    final bool isSelected = selectedDate.day == day && selectedDate.month == now.month;

    return GestureDetector(
      onTap: () {
        onDateSelected(thisDay); // ส่งค่ากลับเมื่อเลือกวัน
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent
              : isToday
                  ? Colors.redAccent
                  : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
          border: isSelected
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected || isToday ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formatter.format(now), // แสดงเดือนและปีปัจจุบัน
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.transparent),
          children: buildCalendar(),
        ),
      ],
    );
  }
}
