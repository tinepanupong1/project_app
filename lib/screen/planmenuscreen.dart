import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanMenuScreen extends StatefulWidget {
  @override
  _PlanMenuScreenState createState() => _PlanMenuScreenState();
}

class _PlanMenuScreenState extends State<PlanMenuScreen> {
  List<Map<String, dynamic>> menus = [];

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // ดึงข้อมูลเมนูตามโรค เช่น Hypertension
    CollectionReference diseaseCollection = firestore.collection('disease');
    DocumentSnapshot documentSnapshot = await diseaseCollection.doc('Hypertension').get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('meals')) {
        List<dynamic> meals = data['meals'];
        setState(() {
          menus = meals.map((meal) => meal as Map<String, dynamic>).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7EB),
      appBar: AppBar(
        title: const Text('Menu Planning', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // แสดงรายการเมนู
            menus.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      return MenuCard(
                        imageUrl: menu['imageUrl'], // URL ของรูปเมนู
                        title: menu['title'], // ชื่อเมนู
                        calories: menu['calories'], // แคลอรี่
                        ingredients: menu['ingredients'], // ส่วนประกอบ
                      );
                    },
                  ),
            const SizedBox(height: 20),
            // ระบบวางแผนเมนู (Drag-and-drop หรือ select)
            PlanningGrid(),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int calories;
  final List<String> ingredients;

  const MenuCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.calories,
    required this.ingredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text("Calories: $calories kcal"),
          const SizedBox(height: 8),
          Text(
            'Ingredients: ${ingredients.join(", ")}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PlanningGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("มิถุนายน 2567", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DayMenuColumn(day: 'จันทร์ 10', meals: ["เช้า", "เที่ยง", "เย็น"]),
                  DayMenuColumn(day: 'อังคาร 11', meals: ["เช้า", "เที่ยง", "เย็น"]),
                  DayMenuColumn(day: 'พุธ 12', meals: ["เช้า", "เที่ยง", "เย็น"]),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Implement save planning logic here
                },
                child: Text("บันทึกแผน"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DayMenuColumn extends StatelessWidget {
  final String day;
  final List<String> meals;

  const DayMenuColumn({Key? key, required this.day, required this.meals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
        ...meals.map((meal) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(meal)),
            ),
          );
        }).toList(),
      ],
    );
  }
}
