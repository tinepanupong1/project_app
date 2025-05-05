import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

typedef Menu = Map<String, dynamic>;

/// แปลง dynamic (String หรือ List) → List<String>
List<String> _toStringList(dynamic raw) {
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String)
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  return [];
}

/// Service สำหรับแนะนำเมนูอาหาร
class RecommendationService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  RecommendationService(this.uid);

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Menu>> _fetchGoalMenus(String? goalType) async {
    final out = <Menu>[];
    if (goalType != null) {
      final docRef = _db.collection('goals').doc(goalType);
      for (var slot in ['meals', 'snacks']) {
        final snap = await docRef.collection(slot).get();
        for (var d in snap.docs) {
          out.add(Map<String, dynamic>.from(d.data())..['slot'] = slot);
        }
      }
    } else {
      for (var g in (await _db.collection('goals').get()).docs) {
        for (var slot in ['meals', 'snacks']) {
          for (var d in (await g.reference.collection(slot).get()).docs) {
            out.add(Map<String, dynamic>.from(d.data())..['slot'] = slot);
          }
        }
      }
    }
    return out;
  }

  Future<List<Menu>> _fetchDiseaseMenus(String? disease) async {
    final out = <Menu>[];
    if (disease != null) {
      final docRef = _db.collection('disease').doc(disease);
      for (var slot in ['meals', 'rice', 'snacks']) {
        final snap = await docRef.collection(slot).get();
        for (var d in snap.docs) {
          out.add(Map<String, dynamic>.from(d.data())..['slot'] = slot);
        }
      }
    } else {
      for (var dd in (await _db.collection('disease').get()).docs) {
        for (var slot in ['meals', 'rice', 'snacks']) {
          for (var d in (await dd.reference.collection(slot).get()).docs) {
            out.add(Map<String, dynamic>.from(d.data())..['slot'] = slot);
          }
        }
      }
    }
    return out;
  }

  double _percentSuitability(double cal, double budget) {
    if (budget <= 0) return 0.0;
    final diffRatio = (cal - budget) / budget;
    final score = exp(-pow(diffRatio, 2));
    return score * 100;
  }

  List<Menu> _pickOne(
    List<Menu> source,
    double budget,
    bool Function(Menu) filterDisease,
    List<String> allergies,
    int seed,
  ) {
    final cand = source.where((m) {
      final ings = _toStringList(m['ingredients']);
      if (allergies.any(
          (a) => ings.any((i) => i.toLowerCase().contains(a.toLowerCase()))))
        return false;
      if (!filterDisease(m)) return false;
      return true;
    }).map((m) {
      final cal = (m['calories'] as num?)?.toDouble() ?? 0.0;
      return {
        ...m,
        'ingredients': _toStringList(m['ingredients']),
        'percent': _percentSuitability(cal, budget),
      };
    }).toList();

    cand.sort(
        (a, b) => (b['percent'] as double).compareTo(a['percent'] as double));
    if (cand.isEmpty) return [];
    final top20 = cand.take(20).toList()..shuffle(Random(seed));
    return [top20.first];
  }

  Future<List<Menu>> recommend({
    required int nMeals,
    required double dailyTarget,
    bool includeSnacks = true,
    int nSnacks = 1,
    int? overrideSeed,
  }) async {
    final profile = await _fetchUserProfile();
    final rawGoal = profile?['goalType'] as String?;
    final rawDisease = profile?['disease'] as String?;

    const goalMap = {
      'ลดน้ำหนัก': 'lose weight',
      'เพิ่มน้ำหนัก': 'gain weight',
      'รักษาน้ำหนัก': 'Maintain weight',
    };
    const diseaseMap = {
      'โรคความดันโลหิตสูง': 'Hypertension',
      'โรคอ้วน': 'Obesity',
      'โรคไต': 'kidney disease',
    };

    final goalKey = goalMap[rawGoal];
    final diseaseKey = diseaseMap[rawDisease];

    final goalMenus = await _fetchGoalMenus(goalKey);
    final diseaseMenus = await _fetchDiseaseMenus(diseaseKey);
    final allMenus = [...goalMenus, ...diseaseMenus];

    final mealSource = allMenus.where((m) => m['slot'] != 'snacks').toList();
    final snackSource = allMenus.where((m) => m['slot'] == 'snacks').toList();

    final allergies = _toStringList(profile?['allergies'])
        .where((a) => a.isNotEmpty)
        .toList();

    bool filterDisease(Menu m) {
      if (diseaseKey == 'Hypertension') {
        final forb = [
          'เกลือ',
          'น้ำปลา',
          'ซีอิ๊ว',
          'ไส้กรอก',
          'กุนเชียง',
          'อาหารกระป๋อง',
          'ผักกาดดอง',
          'ไข่เค็ม',
          'กุ้งแห้ง',
          'ปลาเค็ม'
        ];
        return !_toStringList(m['ingredients'])
            .any((i) => forb.any((kw) => i.contains(kw)));
      } else if (diseaseKey == 'kidney disease') {
        final forb = [
          'เนื้อหมู',
          'เครื่องใน',
          'กะทิ',
          'กล้วย',
          'ฝรั่ง',
          'มะละกอ',
          'ถั่ว'
        ];
        return !_toStringList(m['ingredients'])
            .any((i) => forb.any((kw) => i.contains(kw)));
      }
      return true;
    }

    final seed = overrideSeed ?? DateTime.now().millisecondsSinceEpoch;
    final picks = <Menu>[];

    // ถ้าเลือก 3 มื้อหลัก ให้ใช้สัดส่วน (25%, 35%, 30%)
    if (nMeals == 3) {
      final mealRatios = [0.25, 0.35, 0.30];
      for (var i = 0; i < 3; i++) {
        final budget = dailyTarget * mealRatios[i];
        picks.addAll(
            _pickOne(mealSource, budget, filterDisease, allergies, seed ^ i));
      }
    } else {
      // ถ้าไม่ใช่ 3 มื้อหลัก ให้หาร 90% ของพลังงานเท่า ๆ กัน
      final mealBudget = dailyTarget * 0.90 / nMeals;
      for (var i = 0; i < nMeals; i++) {
        picks.addAll(_pickOne(
            mealSource, mealBudget, filterDisease, allergies, seed ^ i));
      }
    }

    // แนะนำของว่าง 10%
    if (includeSnacks) {
      final snackBudget = dailyTarget * 0.10 / nSnacks;
      for (var j = 0; j < nSnacks; j++) {
        picks.addAll(_pickOne(snackSource, snackBudget, filterDisease,
            allergies, seed ^ (100 + j)));
      }
    }

    return picks;
  }
}

class RecommendationScreen extends StatefulWidget {
  final String userId;
  const RecommendationScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _db = FirebaseFirestore.instance;
  late RecommendationService _service;
  bool _loading = true;
  double _tdee = 0;
  double _remaining = 0;
  List<Menu> _picks = [];
  bool _hasSaved = false;
  int _selectedMeals = 3;
  bool _includeSnacks = true;

  @override
  void initState() {
    super.initState();
    _service = RecommendationService(widget.userId);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations({bool forceNew = false}) async {
    setState(() => _loading = true);
    final docSnap = await _db.collection('users').doc(widget.userId).get();
    final data = docSnap.data()!;
    _tdee = (data['tdee'] as num?)?.toDouble() ?? 0;
    final eaten = (data['eaten_calories'] as num?)?.toDouble() ?? 0;
    _remaining = _tdee - eaten;

    final dateId = DateFormat('d-M-yyyy').format(DateTime.now());
    final planDoc = await _db
        .collection('users')
        .doc(widget.userId)
        .collection('meal_plans')
        .doc(dateId)
        .get();

    if (planDoc.exists && !forceNew) {
      final raw = planDoc.data()!['recommendations'];
      if (raw is List) {
        _hasSaved = true;
        final choice = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('พบแผนวันนี้'),
            content: const Text('ดูแผนเดิมหรือสร้างใหม่?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('ดูแผนเดิม')),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('สร้างใหม่')),
            ],
          ),
        );
        if (choice == true) {
          final recs = raw.whereType<Map>().map((m) {
            final map = Map<String, dynamic>.from(m);
            map['ingredients'] = _toStringList(m['ingredients']);
            return map;
          }).toList();

          // ตั้งค่า _selectedMeals ตามค่าที่บันทึกไว้
          final numMeals =
              planDoc.data()?['numMeals'] ?? 3; // ใช้ค่า numMeals ที่บันทึก
          setState(() {
            _picks = recs;
            _selectedMeals = numMeals; // อัปเดตจำนวนมื้อที่เลือก
            _remaining -= recs.fold<double>(0,
                (sum, m) => sum + ((m['calories'] as num?)?.toDouble() ?? 0));
            _loading = false;
          });
          return;
        }
      }
    }

    final seed = DateTime.now().millisecondsSinceEpoch;
    final picks = await _service.recommend(
      nMeals: _selectedMeals,
      dailyTarget: _remaining,
      includeSnacks: _includeSnacks,
      nSnacks: 1,
      overrideSeed: seed,
    );
    final used = picks.fold<double>(
        0, (sum, m) => sum + ((m['calories'] as num?)?.toDouble() ?? 0));
    // ตัดรายการออกจนไม่เกินงบพลังงาน
    var filtered = List<Menu>.from(picks);
    var totalCalories = used;
    while (filtered.isNotEmpty && totalCalories > _remaining) {
      final removed = filtered.removeLast();
      totalCalories -= (removed['calories'] as num?)?.toDouble() ?? 0;
    }
    final finalUsed = totalCalories;
    final newRemaining = (_remaining - finalUsed).clamp(0, double.infinity);
    setState(() {
      _picks = picks;
      _remaining -= used;
      _hasSaved = false;
      _loading = false;
    });
  }

  Future<void> _savePlan() async {
    final dateId = DateFormat('d-M-yyyy').format(DateTime.now());
    final totalUsed = (_tdee - _remaining).toStringAsFixed(0);
    await _db
        .collection('users')
        .doc(widget.userId)
        .collection('meal_plans')
        .doc(dateId)
        .set({
      'date': dateId,
      'numMeals': _selectedMeals,
      'includeSnacks': _includeSnacks,
      'recommendations': _picks,
      'total_used': totalUsed,
      'remaining': _remaining.toStringAsFixed(0),
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('บันทึกเรียบร้อย')));
    setState(() => _hasSaved = true);
  }

  Color _percentColor(double p) {
    if (p >= 80) return Colors.green.shade400;
    if (p >= 60) return Colors.orange.shade300;
    return Colors.red.shade300;
  }

  Widget _buildCard(int index, Menu m) {
    final img = m['img'] as String?;
    final pct = (m['percent'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final ing = (m['ingredients'] as List<String>).join(', ');
    final isSnack = _includeSnacks && index >= _selectedMeals;
    final label =
        isSnack ? 'ของว่าง ${index - _selectedMeals + 1}' : 'มื้อ ${index + 1}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (img != null && img.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(img,
                  height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(m['food_name'] ?? '', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text(ing, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _percentColor(double.parse(pct)),
                  borderRadius: BorderRadius.circular(4)),
              child: Text('$pct%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'เปอร์เซ็นต์นี้บอกว่าเมนูมีพลังงานใกล้เคียงกับค่าพลังงานของคุณ ยิ่งมากยิ่งเหมาะสม',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'วางแผน $_selectedMeals มื้อ${_includeSnacks ? ' + ของว่าง' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadRecommendations(forceNew: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Text('จำนวนมื้อหลัก:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedMeals,
                    items: [2, 3, 4, 5, 6]
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text('$n มื้อ')))
                        .toList(),
                    onChanged: (n) {
                      if (n != null) {
                        setState(() => _selectedMeals = n);
                        _loadRecommendations(forceNew: true);
                      }
                    },
                  ),
                  const Spacer(),
                  const Text('ของว่าง'),
                  Switch(
                    value: _includeSnacks,
                    onChanged: (v) {
                      setState(() => _includeSnacks = v);
                      _loadRecommendations(forceNew: true);
                    },
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'พลังงานคงเหลือ: ${_remaining.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _picks.length,
                  itemBuilder: (_, i) => _buildCard(i, _picks[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_hasSaved ? 'บันทึกใหม่' : 'บันทึกแผนวันนี้'),
                  onPressed: _savePlan,
                ),
              ),
            ]),
    );
  }
}
