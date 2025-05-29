// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_app/services/recommendation_service.dart';

class ApiService {
  static const _baseUrl = 'http://<SERVER_IP>:5000';

  /// ดึงเมนูแนะนำทั้งชุด (meals,rice,snacks)
  static Future<List<Recommendation>> fetchRecommendations({
    required Map<String,dynamic> userProfile,
    int topN = 5,
  }) async {
    final uri = Uri.parse('$_baseUrl/recommend');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': userProfile,
        'top_n': topN,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load recommendations');
    }
    final data = jsonDecode(resp.body) as Map<String,dynamic>;
    final list = data['recommendations'] as List<dynamic>;
    return list.map((e) => Recommendation.fromJson(e)).toList();
  }

  /// รีเฟรชเมนูเฉพาะ slot เดียว (meals|rice|snacks)
  static Future<List<Recommendation>> refreshSlot({
    required Map<String,dynamic> userProfile,
    required String slot,
    int topN = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/recommend/refresh');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': userProfile,
        'slot': slot,
        'top_n': topN,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to refresh $slot');
    }
    final data = jsonDecode(resp.body) as Map<String,dynamic>;
    final list = data[slot] as List<dynamic>;
    return list.map((e) => Recommendation.fromJson(e)).toList();
  }
}
