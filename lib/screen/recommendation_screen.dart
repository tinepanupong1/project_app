import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RecommendationScreen extends StatefulWidget {
  final String userId;
  const RecommendationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _loading = true;
  Map<String, List<dynamic>> _recs = {};
  Map<String, bool> _slotLoading = {};
  Map<String, String?> _selectedPlan = {
    'breakfast': null,
    'lunch': null,
    'dinner': null,
    'snacks': null,
  };

  static const apiBase = 'http://10.0.2.2:5000';

  @override
  void initState() {
    super.initState();
    _fetchAndRecommend();
  }

  String todayDocId() {
    final now = DateTime.now();
    return '${now.day}-${now.month}-${now.year}';
  }

  Future<void> _fetchAndRecommend() async {
    setState(() => _loading = true);

    final body = {
      'user_id': widget.userId,
      'top_n_meals': 3,
      'top_n_snacks': 2,
    };

    final rResp = await http.post(
      Uri.parse('$apiBase/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (rResp.statusCode == 200) {
      final data = jsonDecode(rResp.body)['recommendations'] as Map<String, dynamic>;
      setState(() {
        _recs = data.map((k, v) => MapEntry(k, List<dynamic>.from(v)));
      });
    } else {
      setState(() => _recs = {});
    }

    setState(() => _loading = false);
  }

  Future<void> _refreshSlot(String slot) async {
    setState(() => _slotLoading[slot] = true);

    final body = {
      'user_id': widget.userId,
      'slot': slot,
      'top_n': slot == 'snacks' ? 2 : 3,
    };

    final rResp = await http.post(
      Uri.parse('$apiBase/recommend/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (rResp.statusCode == 200) {
      final data = jsonDecode(rResp.body) as Map<String, dynamic>;
      setState(() {
        _recs[slot] = List<dynamic>.from(data[slot]);
      });
    }

    setState(() => _slotLoading[slot] = false);
  }

  Future<void> _savePlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('meal_plans')
        .doc(todayDocId());

    await ref.set({
      'date': DateFormat('d/M/yyyy').format(DateTime.now()),
      'meals': _selectedPlan,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('บันทึกแผนสำเร็จ'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('วางแผนเมนู')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('วางแผนเมนู')),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          ..._recs.entries.map((entry) {
            final slot = entry.key;
            final list = entry.value;
            final isSlotLoading = _slotLoading[slot] == true;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _slotLabel(slot),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    isSlotLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.refresh),
                            tooltip: 'รีเฟรช $slot',
                            onPressed: () => _refreshSlot(slot),
                          ),
                  ],
                ),
                if (_selectedPlan[slot] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'เลือกแล้ว: ${_selectedPlan[slot]}',
                      style: TextStyle(color: Colors.green[800]),
                    ),
                  ),
                ...list.map((m) {
                  final ingredients = (m['ingredients'] as List<dynamic>?)?.cast<String>().join(', ') ?? 'ไม่มีข้อมูลส่วนผสม';
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m['img'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                m['img'],
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  m['food_name'] ?? '',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${m['calories']} kcal'),
                                  Text('${m['percent']}%', style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('ส่วนประกอบ: $ingredients', style: TextStyle(color: Colors.grey[700])),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: Icon(Icons.check_circle_outline),
                              label: Text('เลือกเมนูนี้'),
                              onPressed: () {
                                setState(() {
                                  _selectedPlan[slot] = m['food_name'];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
              ],
            );
          }),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _savePlan,
            icon: Icon(Icons.save),
            label: Text('บันทึกแผนวันนี้'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  String _slotLabel(String key) {
    switch (key) {
      case 'breakfast':
        return 'มื้อเช้า';
      case 'lunch':
        return 'มื้อกลางวัน';
      case 'dinner':
        return 'มื้อเย็น';
      case 'snacks':
        return 'ของว่าง';
      default:
        return key;
    }
  }
}
