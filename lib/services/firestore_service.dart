// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   static final _db = FirebaseFirestore.instance;

//   /// ดึงข้อมูลผู้ใช้จาก collection `users`
//   static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     final doc = await _db.collection('users').doc(userId).get();
//     return doc.exists ? doc.data() : null;
//   }

//   /// บันทึกแผนอาหารลงใน collection `meal_plans` แบบละเอียดเหมือน food diary
//   static Future<void> saveMealPlan({
//     required String userId,
//     required String date,
//     required Map<String, dynamic> plan,
//   }) async {
//     // สร้าง entries สำหรับแต่ละมื้อ
//     final List<Map<String, dynamic>> entries = plan.entries.map((entry) {
//       final meal = entry.key;
//       final item = entry.value ?? {};
//       return {
//         'meal': meal,
//         'food': item['food_name'] ?? '-',
//         'image': item['img'] ?? '',
//         'calories': item['calories'] ?? 0,
//         'ingredients': item['ingredients'] ?? [],
//       };
//     }).toList();

//     await _db.collection('meal_plans').add({
//       'userId': userId,
//       'date': date,
//       'entries': entries,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// ดึงเมนูจาก subcollections: meals, rice, snacks จากทั้ง goals และ disease
//   static Future<List<Map<String, dynamic>>> fetchMenusByIds(List<String> ids) async {
//     if (ids.isEmpty) return [];

//     final idStrings = ids.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
//     final List<Map<String, dynamic>> all = [];
//     const subs = ['meals', 'rice', 'snacks'];
//     const goals = ['Maintain weight', 'gain weight', 'lose weight'];
//     const diseases = ['Hypertension', 'Obesity', 'kidney disease'];

//     for (var sub in subs) {
//       for (var i = 0; i < idStrings.length; i += 10) {
//         final batch = idStrings.skip(i).take(10).toList();

//         // จาก disease
//         for (var d in diseases) {
//           final snap = await _db
//               .collection('disease')
//               .doc(d)
//               .collection(sub)
//               .where(FieldPath.documentId, whereIn: batch)
//               .get();

//           for (var doc in snap.docs) {
//             final data = doc.data();
//             data['id'] = doc.id;
//             data['category'] = sub;
//             data['path'] = doc.reference.path;
//             data['source'] = 'disease';
//             all.add(data);
//           }
//         }

//         // จาก goals (เฉพาะ meals และ snacks)
//         if (sub != 'rice') {
//           for (var g in goals) {
//             final snap = await _db
//                 .collection('goals')
//                 .doc(g)
//                 .collection(sub)
//                 .where(FieldPath.documentId, whereIn: batch)
//                 .get();

//             for (var doc in snap.docs) {
//               final data = doc.data();
//               data['id'] = doc.id;
//               data['category'] = sub;
//               data['path'] = doc.reference.path;
//               data['source'] = 'goal';
//               all.add(data);
//             }
//           }
//         }
//       }
//     }

//     return all;
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   static final _db = FirebaseFirestore.instance;

//   /// ดึงข้อมูลผู้ใช้จาก collection `users`
//   static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     final doc = await _db.collection('users').doc(userId).get();
//     return doc.exists ? doc.data() : null;
//   }

//   /// บันทึกแผนอาหารลงใน collection `meal_plans`
//   static Future<void> saveMealPlan({
//     required String userId,
//     required String date,
//     required List<Map<String, dynamic>> entries,
//   }) async {
//     await _db.collection('meal_plans').add({
//       'userId': userId,
//       'date': date,
//       'entries': entries,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// ดึงเมนูจาก subcollections ตาม document IDs
//   static Future<List<Map<String, dynamic>>> fetchMenusByIds(List<String> ids) async {
//     if (ids.isEmpty) return [];
//     final idStrings = ids.where((e) => e.isNotEmpty).toList();
//     final List<Map<String, dynamic>> all = [];
//     const subs = ['meals', 'rice', 'snacks'];
//     const goals = ['Maintain weight', 'gain weight', 'lose weight'];
//     const diseases = ['Hypertension', 'Obesity', 'kidney disease'];

//     for (var sub in subs) {
//       for (var i = 0; i < idStrings.length; i += 10) {
//         final batch = idStrings.skip(i).take(10).toList();
//         // disease
//         for (var d in diseases) {
//           final snap = await _db
//               .collection('disease')
//               .doc(d)
//               .collection(sub)
//               .where(FieldPath.documentId, whereIn: batch)
//               .get();
//           for (var doc in snap.docs) {
//             final data = doc.data();
//             data['id'] = doc.id;
//             data['category'] = sub;
//             data['path'] = doc.reference.path;
//             data['source'] = 'disease';
//             all.add(data);
//           }
//         }
//         // goals (meals & snacks)
//         if (sub != 'rice') {
//           for (var g in goals) {
//             final snap = await _db
//                 .collection('goals')
//                 .doc(g)
//                 .collection(sub)
//                 .where(FieldPath.documentId, whereIn: batch)
//                 .get();
//             for (var doc in snap.docs) {
//               final data = doc.data();
//               data['id'] = doc.id;
//               data['category'] = sub;
//               data['path'] = doc.reference.path;
//               data['source'] = 'goal';
//               all.add(data);
//             }
//           }
//         }
//       }
//     }
//     return all;
//   }

//   /// ดึงเมนูจากทุก subcollection (meals, rice, snacks) ตามชื่อเมนูใน field `food_name`
//   static Future<List<Map<String, dynamic>>> fetchMenusByNames(List<String> names) async {
//     if (names.isEmpty) return [];
//     final List<Map<String, dynamic>> results = [];
//     const subs = ['meals', 'rice', 'snacks'];

//     for (var sub in subs) {
//       // collectionGroup จะค้นทุก subcollection ที่มีชื่อนี้
//       final snap = await _db
//           .collectionGroup(sub)
//           .where('food_name', whereIn: names)
//           .get();
//       for (var doc in snap.docs) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         data['category'] = sub;
//         data['path'] = doc.reference.path;
//         data['source'] = doc.reference.path.startsWith('goals/') ? 'goal' : 'disease';
//         results.add(data);
//       }
//     }

//     return results;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // mapping ภาษาไทย ➔ path ใน Firestore
  static const Map<String, String> _goalMap = {
    'รักษาน้ำหนัก': 'Maintain weight',
    'เพิ่มน้ำหนัก':  'gain weight',
    'ลดน้ำหนัก':   'lose weight',
  };
  static const Map<String, String> _diseaseMap = {
    'โรคความดันโลหิตสูง': 'Hypertension',
    'โรคอ้วน':           'Obesity',
    'โรคไต':            'kidney disease',
  };

  /// ดึงเมนูตาม rule-based: goalTypeTh + diseaseTh + allergies
  Future<List<Map<String, dynamic>>> fetchMenusByRule({
    required String goalTypeTh,
    required String diseaseTh,
    String allergies = '',
  }) async {
    final String? goalEng    = _goalMap[goalTypeTh];
    final String? diseaseEng = _diseaseMap[diseaseTh];

    List<Map<String, dynamic>> menus = [];

    // ดึง disease/{diseaseEng}/{meals,rice,snacks}
    if (diseaseEng != null) {
      for (final sub in ['meals', 'rice', 'snacks']) {
        final snap = await _db
            .collection('disease')
            .doc(diseaseEng)
            .collection(sub)
            .get();
        menus.addAll(snap.docs.map((d) => d.data()));
      }
    }

    // ดึง goals/{goalEng}/{meals,snacks}
    if (goalEng != null) {
      for (final sub in ['meals', 'snacks']) {
        final snap = await _db
            .collection('goals')
            .doc(goalEng)
            .collection(sub)
            .get();
        menus.addAll(snap.docs.map((d) => d.data()));
      }
    }

    // กรองเมนูที่มีส่วนผสมแพ้
    if (allergies.isNotEmpty) {
      menus = menus.where((m) {
        final ings = (m['ingredients'] as List<dynamic>?) ?? [];
        final joined = ings.join(' ').toLowerCase();
        return !joined.contains(allergies.toLowerCase());
      }).toList();
    }

    return menus;
  }
}
