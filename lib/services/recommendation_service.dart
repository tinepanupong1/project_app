// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// // class RecommendationService {
// //   static Future<List<String>> getRecommendedMenus({
// //     required int age,
// //     required String gender,
// //     required String goalType,
// //     required String disease,
// //     required int tdee,
// //   }) async {
// //     final url = Uri.parse('http://10.0.2.2:5000/recommend'); // หรือ 127.0.0.1 สำหรับเว็บ/desktop

// //     final response = await http.post(
// //       url,
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({
// //         "age": age,
// //         "gender": gender,
// //         "goalType": goalType,
// //         "disease": disease,
// //         "tdee": tdee,
// //       }),
// //     );

// //     if (response.statusCode == 200) {
// //       final data = jsonDecode(response.body);
// //       return List<String>.from(data['recommended_menu_ids']);
// //     } else {
// //       throw Exception('แนะนำเมนูล้มเหลว: ${response.body}');
// //     }
// //   }
// // }

// // lib/services/recommendation_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   /// เรียก ML API เพื่อขอรายชื่อเมนูที่แนะนำ (คืนเป็น list ของ document ID ใน Firestore)
//   static Future<List<String>> getRecommendedMenus({
//     required int age,
//     required String gender,
//     required String goalType,
//     required String disease,
//     required int tdee,
//   }) async {
//     final url = Uri.parse('http://10.0.2.2:5000/recommend'); 
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "age": age,
//         "gender": gender,
//         "goalType": goalType,
//         "disease": disease,
//         "tdee": tdee,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<String>.from(data['recommended_menu_ids']);
//     } else {
//       throw Exception('แนะนำเมนูล้มเหลว: ${response.body}');
//     }
//   }
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   static Future<List<String>> getRecommendedMenus({
//     required int age,
//     required String gender,
//     required String goalType,
//     required String disease,
//     required int tdee,
//   }) async {
//     final url = Uri.parse('http://10.0.2.2:5000/recommend'); // ใช้ 10.0.2.2 ถ้าเป็น Emulator

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "age": age,
//         "gender": gender,
//         "goalType": goalType,
//         "disease": disease,
//         "tdee": tdee,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<String>.from(data['recommended_menu_ids']);
//     } else {
//       throw Exception('แนะนำเมนูล้มเหลว: ${response.body}');
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   static Future<List<String>> getRecommendedMenus({
//     required int age,
//     required String gender,
//     required String goalType,
//     required String disease,
//     required int tdee,
//     //required String allergies,
//   }) async {
//      final url = Uri.parse('http://10.0.2.2:5000/recommend'); // ใช้ 10.0.2.2 สำหรับ emulator
//    /*final url = Uri.parse('http://localhost:61840/recommend');*/
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "age": age,
//         "gender": gender,
//         "goalType": goalType,
//         "disease": disease,
//         "tdee": tdee,
//         //"allergies":allergies,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<String>.from(data['recommended_menu_ids']);
//     } else {
//       throw Exception('แนะนำเมนูไม่สำเร็จ: ${response.body}');
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   static Future<List<String>> getRecommendedMenus({
//     required int age,
//     required String gender,
//     required String goalType,
//     required String disease,
//     required int tdee,
//   }) async {
//     final url = Uri.parse('http://10.0.2.2:5000/recommend');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'age': age,
//         'gender': gender,
//         'goalType': goalType,
//         'disease': disease,
//         'tdee': tdee,
//       }),
//     );
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<String>.from(data['recommended_menu_ids']);
//     } else {
//       throw Exception('Failed to get recommendations: ${response.body}');
//     }
//   }
// }


// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   static Future<List<Map<String, dynamic>>> getRecommendedMenus() async {
//     // 1) ดึง profile จาก Firestore
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) throw Exception("ยังไม่ล็อกอิน");
//     final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     final prof = doc.data();
//     if (prof == null) throw Exception("ไม่พบข้อมูลผู้ใช้");

//     // 2) เรียก API
//     final url = Uri.parse("http://10.0.2.2:5000/recommend");
//     final resp = await http.post(url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "age": prof["age"],
//         "gender": prof["gender"],
//         "goalType": prof["goalType"],
//         "disease": prof["disease"],
//         "tdee": prof["tdee"],
//         "allergies": prof["allergies"],
//       }),
//     );
//     if (resp.statusCode != 200) throw Exception("API Error: ${resp.body}");

//     final body = jsonDecode(resp.body);
//     return List<Map<String, dynamic>>.from(body["recommended"]);
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   /// เรียก API Flask เพื่อดึงรายการเมนูแนะนำจาก backend
//   static Future<List<String>> getRecommendedMenus({
//     required int age,
//     required String gender,
//     required String goalType,
//     required String disease,
//     required int tdee,
//     required String allergies,
//   }) async {
//     final url = Uri.parse('http://10.0.2.2:5000/recommend');
    
//     final body = {
//       'age': age,
//       'gender': gender,
//       'goalType': goalType,
//       'disease': disease,
//       'tdee': tdee,
//       'allergies': allergies,
//     };

//     final resp = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );

//     if (resp.statusCode == 200) {
//       final data = jsonDecode(resp.body);
//       final ids = List<String>.from(data['recommended_menu_ids'].map((e) => e.toString()));
//       return ids;
//     } else {
//       print('❌ API ERROR: ${resp.body}');
//       throw Exception('API Error: ${resp.body}');
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RecommendationService {
//   /// เรียก ML API เพื่อขอรายชื่อเมนูที่แนะนำ (คืนเป็น List<String> ของ food_name)
//   static Future<List<String>> getRecommendedMenus({
//     required String goalType,
//     required String disease,
//     required int tdee,
//     required String allergies,
//   }) async {
//     final url = Uri.parse('http://10.0.2.2:5000/recommend');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'goalType': goalType,
//         'disease': disease,
//         'tdee': tdee,
//         'allergies': allergies,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as Map<String, dynamic>;
//       // ดึงชื่อเมนูจาก key "recommended_menus"
//       return List<String>.from(data['recommended_menus'] as List);
//     } else {
//       throw Exception('Failed to get recommended menus: ${response.body}');
//     }
//   }
// }


// models/recommendation.dart
class Recommendation {
  final String foodName;
  final int calories;
  final String? img;
  final double score;
  final List<String>? ingredients;

  Recommendation({
    required this.foodName,
    required this.calories,
    this.img,
    required this.score,
    this.ingredients,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      foodName: json['food_name'] as String,
      calories: (json['calories'] as num).toInt(),
      img: json['img'] as String?,
      score: (json['score'] as num).toDouble(),
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
    );
  }
}
