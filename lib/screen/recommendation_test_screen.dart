// // lib/screen/recommendation_test_screen.dart

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:project_app/services/recommendation_service.dart';
// import 'package:project_app/services/firestore_service.dart';
// import 'package:project_app/widgets/menu_card.dart';

// class TestRecommendationScreen extends StatefulWidget {
//   const TestRecommendationScreen({Key? key}) : super(key: key);

//   @override
//   State<TestRecommendationScreen> createState() => _TestRecommendationScreenState();
// }

// class _TestRecommendationScreenState extends State<TestRecommendationScreen> {
//   bool _loading = false;
//   String? _error;
//   List<Map<String, dynamic>> _menus = [];

//   Future<void> _runRecommendation() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//       _menus = [];
//     });

//     try {
//       // 1. ดึง userId จาก FirebaseAuth
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw Exception('ยังไม่เข้าสู่ระบบ');

//       // 2. ดึงข้อมูลโปรไฟล์จาก Firestore
//       final profile = await FirestoreService.getUserProfile(user.uid);
//       if (profile == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

//       // 3. เรียก API ML เพื่อขอ Recommended menu IDs
//       final ids = await RecommendationService.getRecommendedMenus(
//         age: profile['age'] as int,
//         gender: profile['gender'] as String,
//         goalType: profile['goalType'] as String,
//         disease: profile['disease'] as String,
//         tdee: (profile['tdee'] as num).toInt(),
//       );

//       // 4. ดึงรายละเอียดเมนูจาก Firestore
//       final data = await FirestoreService.fetchMenusByIds(ids);

//       setState(() {
//         _menus = data;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _runRecommendation();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Recommendations'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _runRecommendation,
//           )
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(child: Text('Error: $_error'))
//               : _menus.isEmpty
//                   ? const Center(child: Text('No recommendations'))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(8),
//                       itemCount: _menus.length,
//                       itemBuilder: (ctx, i) {
//                         final m = _menus[i];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             leading: m['img'] != null
//                                 ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(6),
//                                     child: Image.network(
//                                       m['img'],
//                                       width: 56,
//                                       height: 56,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : const SizedBox(width: 56, height: 56),
//                             title: Text(m['food_name'] ?? 'Unknown'),
//                             subtitle: Text('${m['calories'] ?? '-'} kcal'),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }
