import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanMenuScreen extends StatefulWidget {
  final String userId;

  const PlanMenuScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _PlanMenuScreenState createState() => _PlanMenuScreenState();
}

class _PlanMenuScreenState extends State<PlanMenuScreen> {
  static const apiBase = 'http://10.0.2.2:5000';

  bool _loading = true;
  Map<String, List<dynamic>> _menus = {};
  Map<String, String?> _selectedMenus = {
    'breakfast': null,
    'lunch': null,
    'dinner': null,
    'snacks': null,
  };

  final Map<String, String> slotLabels = {
    'breakfast': 'เช้า',
    'lunch': 'กลางวัน',
    'dinner': 'เย็น',
    'snacks': 'ของว่าง',
  };

  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayLabel();
    _fetchRecommendations();
  }

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<void> _fetchRecommendations() async {
    setState(() => _loading = true);

    final resp = await http.post(
      Uri.parse('$apiBase/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'top_n_meals': 3,
        'top_n_snacks': 3
      }),
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final data = json['recommendations'] as Map<String, dynamic>;
      setState(() {
        _menus = data.map((k, v) => MapEntry(k, List<dynamic>.from(v)));
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _selectMenu(String slot) async {
    final choices = _menus[slot] ?? [];
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('เลือกเมนู ${slotLabels[slot]}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            children: choices.map((m) => ListTile(
              title: Text(m['food_name']),
              subtitle: Text('${m['calories']} kcal - ${m['percent']}%'),
              onTap: () => Navigator.pop(ctx, m['food_name']),
            )).toList(),
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _selectedMenus[slot] = selected);
    }
  }

  Future<void> _savePlan() async {
    final body = {
      'user_id': widget.userId,
      'plan': {
        _selectedDay: _selectedMenus,
      }
    };
    final resp = await http.post(
      Uri.parse('$apiBase/meal_plans'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(resp.statusCode == 200 ? 'บันทึกแผนสำเร็จ' : 'บันทึกไม่สำเร็จ'),
    ));
  }

  void _resetMenus() {
    setState(() {
      _selectedMenus = {
        'breakfast': null,
        'lunch': null,
        'dinner': null,
        'snacks': null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('วางแผนเมนู')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('วันที่: $_selectedDay', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'รีเฟรชเมนูแนะนำ',
                        onPressed: () async {
                          await _fetchRecommendations();
                          _resetMenus();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._selectedMenus.entries.map((entry) => ListTile(
                        title: Text(slotLabels[entry.key]!),
                        subtitle: Text(entry.value ?? 'ยังไม่เลือกเมนู'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectMenu(entry.key),
                      )),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _savePlan,
                    icon: const Icon(Icons.save),
                    label: const Text('บันทึกแผนวันนี้'),
                  )
                ],
              ),
            ),
    );
  }
}
