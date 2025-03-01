import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:project_app/component/constant.dart';
import 'package:project_app/screen/bottom_navbar.dart';
import 'package:project_app/screen/goal_screen.dart';
import 'package:project_app/screen/planmenuscreen.dart';
import 'fooddiaryscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tdee = 0;
  double consumedCalories = 680;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDocument.exists && userDocument.data() != null) {
        String gender = userDocument['gender'];
        double weight = (userDocument['weight'] as num).toDouble();
        double height = (userDocument['height'] as num).toDouble();
        int age = userDocument['age'];
        String disease = userDocument['disease'];
        String activity = userDocument['activity'];

        // ตรวจสอบว่า goalType มีอยู่หรือไม่
        String? goalType = userDocument.data()?.containsKey('goalType') == true
            ? userDocument['goalType']
            : null;

        double calculatedTDEE = calculateAndSaveTDEE(
          gender, weight, height, age, disease, activity, goalType
        );

        setState(() {
          tdee = calculatedTDEE;
        });

        await saveTDEEToFirestore(calculatedTDEE);
      }
    }
  }

  double calculateBMR(String gender, double weight, double height, int age, String disease) {
    double bmr = 0.0;
    if (disease == 'โรคอ้วน') {
      bmr = (gender == 'ชาย')
          ? (66 + (13.7 * weight) + (5 * height) - (6.8 * age)) - 500
          : (665 + (9.6 * weight) + (1.8 * height) - (4.7 * age)) - 500;
    } else if (disease == 'โรคไต') {
      bmr = (age < 60) ? 35 * weight : 30 * weight;
    } else {
      bmr = (gender == 'ชาย')
          ? 66 + (13.7 * weight) + (5 * height) - (6.8 * age)
          : 665 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
    }
    return bmr;
  }

  double getActivityFactor(String activity) {
    switch (activity) {
      case 'นั่งทำงานอยู่กับที่และไม่ได้ออกกำลังกายเลย': return 1.2;
      case 'ออกกำลังกายหรือเล่นกีฬาเล็กน้อยประมาณอาทิตย์ละ 1-3 วัน': return 1.375;
      case 'ออกกำลังกายหรือเล่นกีฬาปานกลางประมาณอาทิตย์ละ 3-5 วัน': return 1.55;
      case 'ออกกำลังกายหรือเล่นกีฬาอย่างหนักประมาณอาทิตย์ละ 6-7 วัน': return 1.725;
      case 'ออกกำลังกายหรือเล่นที่กีฬาอย่างหนักมากทุกวันเช้า และเย็น': return 1.9;
      default: return 1.0;
    }
  }

  double calculateAndSaveTDEE(String gender, double weight, double height, int age, String disease, String selectedActivity, String? goalType) {
    double bmr = calculateBMR(gender, weight, height, age, disease);
    double activityFactor = getActivityFactor(selectedActivity);
    double calculatedTDEE = bmr * activityFactor;

    if (goalType != null) {
      if (goalType == 'เพิ่มน้ำหนัก') {
        calculatedTDEE += 500;
      } else if (goalType == 'ลดน้ำหนัก') {
        calculatedTDEE -= 500;
      }
    }
    return calculatedTDEE;
  }

  Future<void> saveTDEEToFirestore(double tdee) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'tdee': tdee,
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
        automaticallyImplyLeading: false,
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
                '${tdee.toStringAsFixed(3)} cal', // แสดงค่า TDEE ด้วยทศนิยม 3 ตำแหน่ง
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
                    'ทานไปแล้ว ${consumedCalories.toStringAsFixed(3)} cal', // ทศนิยม 3 ตำแหน่ง
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
                  'เหลือ ${remainingCalories.toStringAsFixed(3)} cal', // ทศนิยม 3 ตำแหน่ง
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalScreen()), 
        );
      },
      child: Container(
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
      ),
    );
  }
}

class FoodDiaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDiaryScreen()), // สร้าง Route ไปยังหน้าจอ FoodDiaryScreen
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlanMenuScreen()), // สร้าง Route ไปยังหน้าจอ PlanMenuScreen
        );
      },
      child: Container(
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
      ),
    );
  }
}
