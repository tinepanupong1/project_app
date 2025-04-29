// lib/screen/recommendation_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

typedef Menu = Map<String, dynamic>;

/// ช่วยแปลง dynamic (String หรือ List) → List<String>
List<String> _toStringList(dynamic raw) {
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return [];
}

class RecommendationService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  RecommendationService(this.uid);

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Menu>> _fetchAllMenus() async {
    final out = <Menu>[];
    // goals → meals + snacks
    for (var g in (await _db.collection('goals').get()).docs) {
      for (var slot in ['meals', 'snacks']) {
        for (var d in (await g.reference.collection(slot).get()).docs) {
          final m = Map<String, dynamic>.from(d.data())..['slot'] = slot;
          out.add(m);
        }
      }
    }
    // disease → meals + rice + snacks
    for (var ddoc in (await _db.collection('disease').get()).docs) {
      for (var slot in ['meals', 'rice', 'snacks']) {
        for (var d in (await ddoc.reference.collection(slot).get()).docs) {
          final m = Map<String, dynamic>.from(d.data())..['slot'] = slot;
          out.add(m);
        }
      }
    }
    return out;
  }

  static final Map<String, bool Function(Menu)> _diseaseFilters = {
    'โรคความดันโลหิตสูง': (m) {
      final ings = _toStringList(m['ingredients']);
      final forbidden = [
        'เกลือ', 'น้ำปลา', 'ซีอิ๊ว', 'ไส้กรอก', 'กุนเชียง',
        'อาหารกระป๋อง', 'ผักกาดดอง', 'ไข่เค็ม', 'กุ้งแห้ง', 'ปลาเค็ม'
      ];
      return !ings.any((i) => forbidden.any((kw) => i.contains(kw)));
    },
    'โรคไต': (m) {
      final ings = _toStringList(m['ingredients']);
      final forbidden = [
        'เนื้อหมู', 'เครื่องใน', 'กะทิ',
        'กล้วย', 'ฝรั่ง', 'มะละกอ', 'ถั่ว'
      ];
      return !ings.any((i) => forbidden.any((kw) => i.contains(kw)));
    },
    'โรคอ้วน': (_) => true,
    'ลดน้ำหนัก': (_) => true,
    'รักษาน้ำหนัก': (_) => true,
    'เพิ่มน้ำหนัก': (_) => true,
  };

  double _percentSuitability(double cal, double budget) {
    if (budget <= 0) return 0.0;
    final diff = (cal - budget) / budget;
    final score = 1 - diff * diff;
    return (score < 0 ? 0 : score) * 100;
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
      if (allergies.any((a) => ings.any((i) => i.toLowerCase() == a.toLowerCase())))
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

    cand.sort((a, b) => (b['percent'] as double).compareTo(a['percent'] as double));
    final top20 = cand.take(20).toList();
    if (top20.isEmpty) return [];
    top20.shuffle(Random(seed));
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
    final allMenus = await _fetchAllMenus();

    final allergies = _toStringList(profile?['allergies']);
    final disease = profile?['disease'] as String? ?? '';
    final filterDisease = _diseaseFilters[disease] ?? (_) => true;

    final totalSlots = nMeals + (includeSnacks ? nSnacks : 0);
    final budget = dailyTarget / (totalSlots > 0 ? totalSlots : 1);
    final baseSeed = overrideSeed ?? DateTime.now().millisecondsSinceEpoch;

    final picks = <Menu>[];
    for (var i = 0; i < nMeals; i++) {
      picks.addAll(_pickOne(allMenus, budget, filterDisease, allergies, baseSeed ^ i));
    }
    if (includeSnacks) {
      final snacks = allMenus.where((m) => m['slot'] == 'snacks').toList();
      for (var j = 0; j < nSnacks; j++) {
        picks.addAll(_pickOne(snacks, budget, filterDisease, allergies, baseSeed ^ (100 + j)));
      }
    }
    return picks;
  }
}

class RecommendationScreen extends StatefulWidget {
  final String userId;
  const RecommendationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _db = FirebaseFirestore.instance;
  late RecommendationService _service;

  bool _loading = true;
  double _dailyTarget = 0, _eaten = 0, _remaining = 0;
  List<Menu> _picks = [];
  bool _hasSaved = false;

  // สถานะจำนวนมื้อหลัก และ toggle ของว่าง
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

    // ดึง TDEE ตรงๆ แล้วหัก eaten_calories เพื่อหางบที่เหลือ
    final uDoc = await _db.collection('users').doc(widget.userId).get();
    final ud = uDoc.data()!;
    final tdee = (ud['tdee'] as num?)?.toDouble() ?? 0;
    _eaten = (ud['eaten_calories'] as num?)?.toDouble() ?? 0;
    _remaining = tdee - _eaten;

    // ตรวจหาแผนเดิมใน Firestore และถามถ้าไม่ forceNew
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
                child: const Text('ดูเมนูเดิม'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('แนะนำเมนูใหม่'),
              ),
            ],
          ),
        );
        if (choice == true) {
          final recs = raw.whereType<Map>().map((m) {
            final map = Map<String, dynamic>.from(m);
            map['ingredients'] = _toStringList(map['ingredients']);
            return map;
          }).toList();
          final used = recs.fold<double>(
              0, (sum, m) => sum + ((m['calories'] as num?)?.toDouble() ?? 0));
          setState(() {
            _picks = recs;
            _remaining -= used;
            _loading = false;
          });
          return;
        }
      }
    }

    // สร้าง recommendation ใหม่ ด้วยงบที่เหลือจาก TDEE
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
    setState(() {
      _picks = picks;
      _remaining -= used;
      _hasSaved = false;
      _loading = false;
    });
  }

  Future<void> _savePlan() async {
    final dateId = DateFormat('d-M-yyyy').format(DateTime.now());
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
      'total_used': (_dailyTarget - _remaining).toStringAsFixed(0),
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

  Widget _buildCard(int i, Menu m) {
    final img = m['img'] as String?;
    final percent = (m['percent'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final ing = (m['ingredients'] as List<String>).join(', ');
    final isSnack = _includeSnacks && i >= _selectedMeals;
    final label =
        isSnack ? 'ของว่าง ${i - _selectedMeals + 1}' : 'มื้อ ${i + 1}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(m['food_name'] ?? '',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text(ing, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _percentColor(double.parse(percent)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$percent%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'เปอร์เซ็นต์นี้บอกว่าเมนูมีพลังงานใกล้เคียงพลังงานที่ต้องการของคุณมากแแค่ไหน\n'
                'ยิ่งเปอร์เซ็นต์สูง → เมนูยิ่งเหมาะกับคุณ',
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
              onPressed: () => _loadRecommendations(forceNew: true)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // เลือกจำนวนมื้อหลัก + toggle ของว่าง
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Text('จำนวนมื้อหลัก:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedMeals,
                    items: [2, 3, 4, 5, 6]
                        .map((n) => DropdownMenuItem(
                              value: n,
                              child: Text('$n'),
                            ))
                        .toList(),
                    onChanged: (n) {
                      if (n == null) return;
                      setState(() => _selectedMeals = n);
                      _loadRecommendations(forceNew: true);
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

              // งบพลังงานคงเหลือ
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'งบพลังงานคงเหลือ: ${_remaining.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // รายการเมนู
              Expanded(
                child: ListView.builder(
                  itemCount: _picks.length,
                  itemBuilder: (_, i) => _buildCard(i, _picks[i]),
                ),
              ),

              // ปุ่มบันทึก
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                      _hasSaved ? 'บันทึกใหม่' : 'บันทึกแผนวันนี้'),
                  onPressed: _savePlan,
                ),
              ),
            ]),
    );
  }
}
