import 'package:flutter/material.dart';
import 'package:project_app/component/constant.dart';
import 'package:project_app/screen/bottom_navbar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: backgroundPink),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CalorieCard(),
            const SizedBox(height: 30),
            GoalAndDiaryRow(),
            const SizedBox(height: 20),
            MenuPlanningCard(),
            const Spacer(),
            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class CalorieCard extends StatefulWidget {
  @override
  State<CalorieCard> createState() => _CalorieCardState();
}

class _CalorieCardState extends State<CalorieCard> {
  @override
  Widget build(BuildContext context) {
    final int totalCalories = 1364;
    final int consumedCalories = 680;
    final int remainingCalories = totalCalories - consumedCalories;
    final double percentConsumed = consumedCalories / totalCalories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundHead,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          //เงา
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
              padding: const EdgeInsets.only(
                  top: 16.0), // เพิ่มพื้นที่ว่างด้านบนของ footer
              child: Text(
                '$totalCalories cal',
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
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: backgroundYellow,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'ทานไปแล้ว $consumedCalories cal',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                    color: backgroundPink,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      //เงา
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10.0,
                        offset: const Offset(0, 5),
                      ),
                    ]),
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
        color: backgroundBlue,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
                      //เงา
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10.0,
                        offset: const Offset(0, 5),
                      ),
                    ]
      ),
      child: const Column(
        children: [
          Image(image: AssetImage('assets/images/G.png'),height: 50,),
          SizedBox(height: 10),
          Text('Goal', style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

class FoodDiaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
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
        children: [Text('Food Diary', style: TextStyle(fontSize: 16, color: Colors.white)),
          
          SizedBox(height: 10),
          Image(image: AssetImage("assets/images/FoodDiary.png"), height: 50,),
        ],
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
        color: Colors.white,
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
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'มื้อเที่ยงวันนี้',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ก๋วยเตี๋ยวต้มยำ',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
