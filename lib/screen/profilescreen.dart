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

  // Controllers
  final nameController     = TextEditingController();
  final genderController   = TextEditingController();
  final ageController      = TextEditingController();
  final weightController   = TextEditingController();
  final heightController   = TextEditingController();
  final diseaseController  = TextEditingController();
  final activityController = TextEditingController();
  final newAllergyController = TextEditingController();

  // Internal list for allergies
  List<String> _allergiesList = [];

  // Chart data
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

  Future<void> _fetchProfileData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;

    nameController.text   = data['name']   as String? ?? '';
    genderController.text = data['gender'] as String? ?? '';
    ageController.text    = (data['age']   as num?)?.toString() ?? '';
    weightController.text= (data['weight']  as num?)?.toString() ?? '';
    heightController.text= (data['height']  as num?)?.toString() ?? '';
    diseaseController.text = data['disease'] as String? ?? '';

    final rawAllergy = data['allergies'];
    if (rawAllergy is List) {
      _allergiesList = rawAllergy.map((e) => e.toString()).toList();
    } else if (rawAllergy is String && rawAllergy.isNotEmpty) {
      _allergiesList = rawAllergy.split(',').map((e) => e.trim()).toList();
    } else {
      _allergiesList = [];
    }

    activityController.text = data['activity'] as String? ?? '';

    setState(() {});
  }

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
    return h > 0 ? w / ((h / 100) * (h / 100)) : 0;
  }

  void _editProfile() {
    final tmpName     = TextEditingController(text: nameController.text);
    final tmpGender   = TextEditingController(text: genderController.text);
    final tmpAge      = TextEditingController(text: ageController.text);
    final tmpWeight   = TextEditingController(text: weightController.text);
    final tmpHeight   = TextEditingController(text: heightController.text);
    final tmpDisease  = TextEditingController(text: diseaseController.text);
    final tmpActivity = TextEditingController(text: activityController.text);
    final tmpAllergies = List<String>.from(_allergiesList);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Jua', fontSize: 30, fontWeight: FontWeight.w500,
              color: Color(0xFF2A505A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', tmpName),
                _buildTextField('Gender', tmpGender),
                _buildTextField('Age', tmpAge),
                _buildTextField('Weight', tmpWeight),
                _buildTextField('Height', tmpHeight),
                _buildDiseaseDropdown(),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold))),
                Wrap(
                  spacing: 6,
                  children: tmpAllergies.map((allergy) => Chip(
                    label: Text(allergy),
                    onDeleted: () => setDialogState(() => tmpAllergies.remove(allergy)),
                  )).toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newAllergyController,
                        decoration: const InputDecoration(labelText: 'เพิ่มอาหารแพ้'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final val = newAllergyController.text.trim();
                        if (val.isNotEmpty && !tmpAllergies.contains(val)) {
                          setDialogState(() => tmpAllergies.add(val));
                          newAllergyController.clear();
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
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
                nameController.text     = tmpName.text;
                genderController.text   = tmpGender.text;
                ageController.text      = tmpAge.text;
                weightController.text   = tmpWeight.text;
                heightController.text   = tmpHeight.text;
                diseaseController.text  = tmpDisease.text;
                activityController.text = tmpActivity.text;
                _allergiesList          = List<String>.from(tmpAllergies);

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                  'name':      nameController.text,
                  'gender':    genderController.text,
                  'age':       int.tryParse(ageController.text) ?? 0,
                  'weight':    double.tryParse(weightController.text) ?? 0,
                  'height':    double.tryParse(heightController.text) ?? 0,
                  'disease':   diseaseController.text,
                  'allergies': _allergiesList,
                  'activity':  activityController.text,
                });
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
      items: diseases.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) => setState(() => diseaseController.text = v ?? ''),
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
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Activity'),
      value: activityController.text.isEmpty ? null : activityController.text,
      items: acts.map((a) => DropdownMenuItem(
            value: a,
            child: Text(
              a,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          )).toList(),
      onChanged: (v) => setState(() => activityController.text = v ?? ''),
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
            Text(
              chartTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                              rightTitles: SideTitles(showTitles: true, interval: 500, getTitles: (v) => v.toInt().toString(), reservedSize: 40, margin: 8),
                              bottomTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitles: (v) => v.toInt().toString(),
                                reservedSize: 24,
                                margin: 8,
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
            // Profile card
            ProfileCard(
              name:     nameController.text,
              gender:   genderController.text,
              age:      int.tryParse(ageController.text)    ?? 0,
              weight:   double.tryParse(weightController.text) ?? 0,
              height:   double.tryParse(heightController.text) ?? 0,
              disease:  diseaseController.text,
              allergy:  _allergiesList.join(', '),
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

// ProfileCard widget
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
          _buildInfoRow('โรคที่เป็น', disease.isNotEmpty ? disease : '-'),
          _buildInfoRow('อาหารแพ้', allergy.isNotEmpty ? allergy : '-'),
          _buildInfoRow('กิจกรรม', activity.isNotEmpty ? activity : '-'),
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
