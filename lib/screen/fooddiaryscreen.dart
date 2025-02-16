import 'package:flutter/material.dart';
import 'searchmenuscreen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodDiaryScreen extends StatefulWidget {
  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  int currentPage = 0;

  String _getFormattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Stream<DocumentSnapshot> _getFoodDiaryStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("food_diary")
        .doc(_getFormattedDate(selectedDate))
        .snapshots();
  }

  void _onDateSelected(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      currentPage = 0;
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchMenuScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getFoodDiaryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "ไม่มีเมนูสำหรับวันนี้",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          if (!data.containsKey("entries") || data["entries"] == null) {
            return const Center(
              child: Text(
                "ไม่มีเมนูสำหรับวันนี้",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          List<dynamic> entries = data["entries"];
          List<Map<String, dynamic>> foodDiary = entries.map((entry) {
            return {
              'meal': entry['meal'] ?? "ไม่ระบุ",
              'food': entry['food'] ?? "ไม่ระบุ",
              'calories': "${entry['calories'] ?? 0} kcal",
              'image': entry['image'] ?? 'assets/images/default_food.png',
            };
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 20),

              // ✅ PageView ที่สามารถเลื่อนได้
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: foodDiary.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final currentMeal = foodDiary[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                currentMeal['image'],
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_food.png',
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentMeal['meal'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${currentMeal['food']} : ${currentMeal['calories']}',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ✅ ปุ่มเลื่อนซ้าย-ขวา
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.pink),
                    onPressed: () {
                      if (currentPage > 0) {
                        pageController.animateToPage(
                          currentPage - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.pink),
                    onPressed: () {
                      if (currentPage < foodDiary.length - 1) {
                        pageController.animateToPage(
                          currentPage + 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✅ ปฏิทินที่แสดงด้านล่าง
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    CustomCalendarWidget(
                      now: now,
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  final DateFormat formatter = DateFormat('MMM y'); 

  List<TableRow> buildCalendar() {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    int dayOfWeek = firstDayOfMonth.weekday;
    List<TableRow> rows = [];

    List<Widget> firstRow = List.generate(7, (index) {
      if (index < dayOfWeek - 1) {
        return const SizedBox(); 
      } else {
        return buildDayCell(index - dayOfWeek + 2);
      }
    });
    rows.add(TableRow(children: firstRow));

    int day = 8 - dayOfWeek;
    while (day <= daysInMonth) {
      List<Widget> weekRow = List.generate(7, (index) {
        if (day <= daysInMonth) {
          return buildDayCell(day++);
        } else {
          return const SizedBox(); 
        }
      });
      rows.add(TableRow(children: weekRow));
    }

    return rows;
  }

  Widget buildDayCell(int day) {
    final DateTime today = DateTime.now();
    final DateTime thisDay = DateTime(now.year, now.month, day);
    final bool isToday = today.day == day && today.month == now.month && today.year == now.year;
    final bool isSelected = selectedDate.day == day && selectedDate.month == now.month;

    return GestureDetector(
      onTap: () {
        onDateSelected(thisDay); 
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
          formatter.format(now),
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






/*import 'package:flutter/material.dart';
import 'searchmenuscreen.dart'; // นำเข้า MenuScreen
import 'package:intl/intl.dart';

class FoodDiaryScreen extends StatefulWidget {
  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final DateTime now = DateTime.now(); // วันเวลาปัจจุบัน
  DateTime selectedDate = DateTime.now(); // เก็บค่าวันที่เลือก
  final PageController pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  int currentPage = 0; // เริ่มต้นที่มื้อเช้า

  final List<Map<String, String>> foodDiary = [
    {
      'meal': 'มื้อเช้า',
      'food': 'ข้าวต้มหมู',
      'calories': '300 kcal',
      'image': 'assets/images/porridge_pork.png',
    },
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
    if (currentPage < foodDiary.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // เลื่อนไปยังหน้าแรกเมื่ออยู่ที่หน้าสุดท้าย
      pageController.jumpToPage(0);
    }
  }

  void previousMeal() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // เลื่อนไปยังหน้าสุดท้ายเมื่ออยู่ที่หน้าแรก
      pageController.jumpToPage(foodDiary.length - 1);
    }
  }

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchMenuScreen()), 
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
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.pink),
                    onPressed: previousMeal, // ปุ่ม previous จะเลื่อนไปยังหน้าสุดท้ายเมื่ออยู่ที่หน้าแรก
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: foodDiary.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index; // อัปเดต currentPage เมื่อมีการเปลี่ยนการ์ด
                      });
                    },
                    itemBuilder: (context, index) {
                      final currentMeal = foodDiary[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  currentMeal['image']!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 120);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentMeal['meal']!,
                                style: const TextStyle(
                                  fontSize: 20,
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
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.pink),
                    onPressed: nextMeal, // ปุ่ม next จะเลื่อนไปยังหน้าแรกเมื่ออยู่ที่หน้าสุดท้าย
                  ),
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
                        selectedDate = date;
                      });
                    },
                  ),
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

  final DateFormat formatter = DateFormat('MMM y'); 

  List<TableRow> buildCalendar() {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    int dayOfWeek = firstDayOfMonth.weekday;
    List<TableRow> rows = [];

    List<Widget> firstRow = List.generate(7, (index) {
      if (index < dayOfWeek - 1) {
        return const SizedBox(); 
      } else {
        return buildDayCell(index - dayOfWeek + 2);
      }
    });
    rows.add(TableRow(children: firstRow));

    int day = 8 - dayOfWeek;
    while (day <= daysInMonth) {
      List<Widget> weekRow = List.generate(7, (index) {
        if (day <= daysInMonth) {
          return buildDayCell(day++);
        } else {
          return const SizedBox(); 
        }
      });
      rows.add(TableRow(children: weekRow));
    }

    return rows;
  }

  Widget buildDayCell(int day) {
    final DateTime today = DateTime.now();
    final DateTime thisDay = DateTime(now.year, now.month, day);
    final bool isToday = today.day == day && today.month == now.month && today.year == now.year;
    final bool isSelected = selectedDate.day == day && selectedDate.month == now.month;

    return GestureDetector(
      onTap: () {
        onDateSelected(thisDay); 
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
          formatter.format(now),
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
*/