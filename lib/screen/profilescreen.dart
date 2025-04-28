import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_app/component/constant.dart';
import 'package:project_app/screen/homescreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String uid;

  // Controllers สำหรับข้อมูลส่วนตัว
  final nameController     = TextEditingController();
  final genderController   = TextEditingController();
  final ageController      = TextEditingController();
  final weightController   = TextEditingController();
  final heightController   = TextEditingController();
  final diseaseController  = TextEditingController();
  final allergyController  = TextEditingController();
  final activityController = TextEditingController();

  // กราฟรายวัน
  List<FlSpot> _calorieSpots = [];
  bool _isChartLoading = true;
  int _daysInMonth = 30;

  static const Map<int, String> monthNames = {
    1: 'ม.ค.',  2: 'ก.พ.',  3: 'มี.ค.', 4: 'เม.ย.',
    5: 'พ.ค.',  6: 'มิ.ย.',  7: 'ก.ค.', 8: 'ส.ค.',
    9: 'ก.ย.', 10: 'ต.ค.', 11: 'พ.ย.', 12: 'ธ.ค.',
  };

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _fetchProfileData();
    _fetchDailyCalorieData();
  }

  /// 1. โหลดข้อมูลโปรไฟล์
  Future<void> _fetchProfileData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) return;

    final data = doc.data()!;
    nameController.text     = data['name']      ?? '';
    genderController.text   = data['gender']    ?? '';
    ageController.text      = (data['age']      ?? '').toString();
    weightController.text   = (data['weight']   ?? '').toString();
    heightController.text   = (data['height']   ?? '').toString();
    diseaseController.text  = data['disease']   ?? '';
    allergyController.text  = data['allergies'] ?? '';
    activityController.text = data['activity']  ?? '';
    setState(() {});
  }

  /// 2. โหลด Food Diary เดือนปัจจุบัน แล้วรวมแคลอรี่เป็นรายวัน
  Future<void> _fetchDailyCalorieData() async {
    final now   = DateTime.now();
    final year  = now.year;
    final month = now.month;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('food_diary')
        .get();

    final Map<int, double> dailyTotals = {};
    for (final doc in snap.docs) {
      final date = DateTime.tryParse(doc.id);
      if (date != null && date.year == year && date.month == month) {
        final entries = doc.data()['entries'] as List<dynamic>? ?? [];
        final sumCal = entries.fold<double>(
          0,
          (sum, e) => sum + (e['calories'] as num).toDouble(),
        );
        dailyTotals[date.day] = sumCal;
      }
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final spots = List<FlSpot>.generate(daysInMonth, (i) {
      final day = i + 1;
      return FlSpot(day.toDouble(), dailyTotals[day] ?? 0);
    });

    setState(() {
      _daysInMonth    = daysInMonth;
      _calorieSpots   = spots;
      _isChartLoading = false;
    });
  }

  double _calculateBMI() {
    final w = double.tryParse(weightController.text) ?? 0;
    final h = double.tryParse(heightController.text) ?? 0;
    if (h > 0) return w / ((h / 100) * (h / 100));
    return 0;
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        title: const Text('Edit Profile', style: TextStyle(
          fontFamily: 'Jua', fontSize: 30, fontWeight: FontWeight.w500,
          color: Color(0xFF2A505A),
        )),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Name', nameController),
              _buildTextField('Gender', genderController),
              _buildTextField('Age', ageController),
              _buildTextField('Weight', weightController),
              _buildTextField('Height', heightController),
              _buildDiseaseDropdown(),
              _buildTextField('Allergy', allergyController),
              _buildActivityDropdown(),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.green)),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users').doc(uid).update({
                'name':      nameController.text,
                'gender':    genderController.text,
                'age':       int.tryParse(ageController.text) ?? 0,
                'weight':    double.tryParse(weightController.text) ?? 0,
                'height':    double.tryParse(heightController.text) ?? 0,
                'disease':   diseaseController.text,
                'allergies': allergyController.text,
                'activity':  activityController.text,
              });
              setState(() {});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctl) =>
    TextField(controller: ctl, decoration: InputDecoration(labelText: label));

  Widget _buildDiseaseDropdown() {
    const diseases = ['โรคอ้วน','โรคไต','โรคความดันโลหิตสูง','ไม่เป็นโรค'];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Disease'),
      value: diseaseController.text.isEmpty ? null : diseaseController.text,
      items: diseases.map((d)=> DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v)=> setState(()=> diseaseController.text = v ?? ''),
    );
  }

  Widget _buildActivityDropdown() {
    const acts = [
      'นั่งทำงานอยู่กับที่และไม่ได้ออกกำลังกายเลย',
      'ออกกำลังกายหรือเล่นกีฬาเล็กน้อยประมาณอาทิตย์ละ 1-3 วัน',
      'ออกกำลังกายหรือเล่นกีฬาปานกลางประมาณอาทิตย์ละ 3-5 วัน',
      'ออกกำลังกายหรือเล่นกีฬาอย่างหนักประมาณอาทิตย์ละ 6-7 วัน',
      'ออกกำลังกายหรือเล่นที่กีฬาอย่างหนักมากทุกวันเช้า และเย็น',
    ];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Activity'),
      value: activityController.text.isEmpty ? null : activityController.text,
      items: acts.map((a)=> DropdownMenuItem(value: a, child: Text(a))).toList(),
      onChanged: (v)=> setState(()=> activityController.text = v ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now        = DateTime.now();
    final bmi        = _calculateBMI();
    final chartTitle = 'กราฟแคลอรี่รายวัน เดือน ${monthNames[now.month]}';

    return Scaffold(
      backgroundColor: const Color(0xFFF6E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua', fontSize: 30, fontWeight: FontWeight.w500,
          color: Color(0xFF2A505A),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= หัวกราฟ =======
            Text(
              chartTitle,
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // ======= กราฟรายวัน =======
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: const Color.fromARGB(255, 251, 253, 252),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  height: 240,
                  child: _isChartLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: _daysInMonth.toDouble(),
                            minY: 0,
                            maxY: 2500,
                            titlesData: FlTitlesData(
                              leftTitles: SideTitles(showTitles: false),
                              rightTitles: SideTitles(
                                showTitles: true,
                                interval: 500,
                                getTitles: (v) => v.toInt().toString(),
                                reservedSize: 40,
                                margin: 8,
                              ),
                              bottomTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitles: (v) => v.toInt().toString(),
                              ),
                              topTitles: SideTitles(showTitles: false),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _calorieSpots,
                                isCurved: true,
                                dotData: FlDotData(show: true),
                                barWidth: 3,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ======= ข้อมูลส่วนตัว =======
            ProfileCard(
              name:     nameController.text,
              gender:   genderController.text,
              age:      int.tryParse(ageController.text)    ?? 0,
              weight:   double.tryParse(weightController.text) ?? 0,
              height:   double.tryParse(heightController.text) ?? 0,
              disease:  diseaseController.text,
              allergy:  allergyController.text,
              activity: activityController.text,
              bmi:      bmi,
              onEdit:   _editProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// ProfileCard widget (ไม่แก้)
class ProfileCard extends StatelessWidget {
  final String name, gender, disease, allergy, activity;
  final int age;
  final double weight, height, bmi;
  final VoidCallback onEdit;

  const ProfileCard({
    required this.name, required this.gender, required this.age,
    required this.weight, required this.height, required this.disease,
    required this.allergy, required this.activity, required this.bmi,
    required this.onEdit, Key? key
  }) : super(key: key);

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCC66A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ข้อมูลส่วนตัว', style: TextStyle(fontSize: 20, color: Color(0xFF2A505A))),
              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF2A505A)), onPressed: onEdit),
            ],
          ),
          _buildInfoRow('ชื่อ', name),
          _buildInfoRow('เพศ', gender),
          _buildInfoRow('อายุ', '$age'),
          _buildInfoRow('น้ำหนัก', '$weight kg'),
          _buildInfoRow('ส่วนสูง', '$height cm'),
          _buildInfoRow('โรคที่เป็น', disease),
          _buildInfoRow('อาหารแพ้', allergy),
          _buildInfoRow('กิจกรรม', activity),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text('BMI: ${bmi.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
