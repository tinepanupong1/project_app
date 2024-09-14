import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // สำหรับ Firebase Authentication
import 'package:percent_indicator/percent_indicator.dart';
import 'package:project_app/component/constant.dart';
import 'package:project_app/screen/bottom_navbar.dart';
import 'fooddiaryscreen.dart';  // นำเข้าหน้าจอ Food Diary

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tdee = 0;  // ค่าเริ่มต้นของ TDEE
  double consumedCalories = 680;  // ตัวอย่างค่าที่บริโภคไปแล้ว

  @override
  void initState() {
    super.initState();
    fetchTDEE();  // ดึงข้อมูล TDEE จาก Firestore
  }

  // ฟังก์ชันสำหรับดึงข้อมูล TDEE จาก Firestore ตาม UID ของผู้ใช้ที่ล็อกอิน
  void fetchTDEE() async {
    // รับค่า UID ของผู้ใช้ที่ล็อกอิน
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ดึงข้อมูลจาก Firestore ที่สอดคล้องกับ UID
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)  // ใช้ UID ของผู้ใช้
          .get();

      setState(() {
        tdee = userDocument['tdee'];  // รับค่า TDEE จาก Firestore
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double remainingCalories = tdee - consumedCalories;
    final double percentConsumed = (tdee > 0) ? consumedCalories / tdee : 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Meal Master'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColorTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: backgroundPink),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CalorieCard(
              tdee: tdee,
              consumedCalories: consumedCalories,
              remainingCalories: remainingCalories,
              percentConsumed: percentConsumed,
            ),
            const SizedBox(height: 30),
            GoalAndDiaryRow(),
            const SizedBox(height: 20),
            MenuPlanningCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class CalorieCard extends StatelessWidget {
  final double tdee;
  final double consumedCalories;
  final double remainingCalories;
  final double percentConsumed;

  const CalorieCard({
    Key? key,
    required this.tdee,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.percentConsumed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundHead,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            percent: percentConsumed,
            center: const Icon(
              Icons.fastfood_sharp,
              size: 40.0,
              color: Colors.white,
            ),
            progressColor: backgroundYellow,
            backgroundColor: backgroundHead2,
            circularStrokeCap: CircularStrokeCap.round,
            footer: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '$tdee cal',  // แสดงค่า TDEE ที่ดึงจาก Firebase
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ปริมาณแคลอรี่ในวันนี้',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: backgroundYellow,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ทานไปแล้ว $consumedCalories cal',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: backgroundPink,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'เหลือ $remainingCalories cal',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalAndDiaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: GoalCard()),
        const SizedBox(width: 16),
        Expanded(child: FoodDiaryCard()),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Image(
            image: AssetImage('assets/images/G.png'),
            height: 50,
          ),
          SizedBox(height: 10),
          Text('Goal', style: TextStyle(fontSize: 16, color: backgroundBlue)),
        ],
      ),
    );
  }
}

class FoodDiaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ใช้ Navigator.push เพื่อไปที่หน้า FoodDiaryScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDiaryScreen()),  // สร้าง Route ไปยังหน้าจอ FoodDiaryScreen
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundBlue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: const Column(
          children: [
            Text('Food Diary', style: TextStyle(fontSize: 16, color: Colors.white)),
            SizedBox(height: 10),
            Image(
              image: AssetImage("assets/images/FoodDiary.png"),
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPlanningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundYellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/healthy.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu Planning',
                style: TextStyle(
                  color: backgroundHead,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'มื้อเที่ยงวันนี้',
                  style: TextStyle(
                    color: backgroundYellow,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ก๋วยเตี๋ยวต้มยำ',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
