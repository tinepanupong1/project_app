// menu_rule_based_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuRuleBasedService {
  static Future<List<Map<String, dynamic>>> getRecommendedMenus(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return [];

    final userData = userDoc.data()!;
    final String goal = userData['goalType'] ?? '';
    final String disease = userData['disease'] ?? '';
    final String allergies = (userData['allergies'] ?? '').toLowerCase();

    List<Map<String, dynamic>> allMenus = [];

    final goalEng = _convertGoalToEnglish(goal);
    final diseaseEng = _convertDiseaseToEnglish(disease);

    final sources = [
      'goals/$goalEng/meals',
      'goals/$goalEng/snacks',
      'disease/$diseaseEng/meals',
      'disease/$diseaseEng/snacks',
    ];

    for (final path in sources) {
      final snap = await FirebaseFirestore.instance.collection(path).get();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (_passesRules(data, allergies, goal)) {
          allMenus.add(data);
        }
      }
    }

    return allMenus;
  }

  static String _convertGoalToEnglish(String goal) {
    switch (goal) {
      case 'ลดน้ำหนัก':
        return 'lose weight';
      case 'เพิ่มน้ำหนัก':
        return 'gain weight';
      case 'รักษาน้ำหนัก':
        return 'Maintain weight';
      default:
        return '';
    }
  }

  static String _convertDiseaseToEnglish(String disease) {
    switch (disease) {
      case 'โรคอ้วน':
        return 'Obesity';
      case 'โรคความดันโลหิตสูง':
        return 'Hypertension';
      case 'โรคไต':
        return 'kidney disease';
      default:
        return '';
    }
  }

  static bool _passesRules(Map<String, dynamic> menu, String allergies, String goal) {
    final ingredients = List<String>.from(menu['ingredients'] ?? []);
    final calories = menu['calories'] ?? 0;

    for (final item in ingredients) {
      if (allergies.contains(item.toLowerCase())) return false;
    }

    if (goal == 'ลดน้ำหนัก' && calories > 400) return false;
    if (goal == 'เพิ่มน้ำหนัก' && calories < 200) return false;

    return true;
  }
}