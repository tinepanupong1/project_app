import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'searchmenuscreen.dart';

class FoodDiaryScreen extends StatefulWidget {
  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  int currentPage = 0;
  List<Map<String, dynamic>> foodDiary = [];

  String _getFormattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _fetchFoodDiary() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String formattedDate = _getFormattedDate(selectedDate);
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("food_diary")
        .doc(formattedDate)
        .get();

    setState(() {
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        foodDiary = List<Map<String, dynamic>>.from(data["entries"] ?? []);
      } else {
        foodDiary = [];
      }
      currentPage = 0;
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
    });
  }

  void _deleteMeal(int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String formattedDate = _getFormattedDate(selectedDate);

    setState(() {
      foodDiary.removeAt(index);
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("food_diary")
        .doc(formattedDate)
        .update({"entries": foodDiary});

    _fetchFoodDiary();
  }

  void nextMeal() {
    if (currentPage < foodDiary.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.jumpToPage(0);
    }
  }

  void previousMeal() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.jumpToPage(foodDiary.length - 1);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFoodDiary();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFoodDiary();
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          foodDiary.isEmpty
              ? const Center(
                  child: Text(
                    "ไม่มีเมนูสำหรับวันนี้",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : SizedBox(
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
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: SizedBox(
                                        height: 120,
                                        width: 150,
                                        child: Image.network(
                                          currentMeal['image'] ?? 'assets/images/default_food.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/food.png',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    currentMeal['meal'] ?? "ไม่ระบุ",
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
                                      '${currentMeal['food'] ?? "ไม่ระบุ"} : ${currentMeal['calories'] ?? "0 kcal"}',
                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _deleteMeal(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.pink),
                onPressed: previousMeal,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.pink),
                onPressed: nextMeal,
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                CustomCalendarWidget(
                  now: now,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                      currentPage = 0;
                    });
                    _fetchFoodDiary();
                    if (pageController.hasClients) {
                      pageController.jumpToPage(0);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
      onTap: () => onDateSelected(thisDay),
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
