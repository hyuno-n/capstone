import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraProvider extends ChangeNotifier {
  final List<String> _rtspUrls = [];

  List<String> get rtspUrls => _rtspUrls;
  Future<void> addCamera(String rtspUrl, String userId) async {
    _rtspUrls.add(rtspUrl);
    notifyListeners(); // UI에 변경 사항 알림

    // 데이터베이스에 카메라 추가 요청
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/add_camera'; // 적절한 엔드포인트로 변경
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'rtsp_url': rtspUrl,
        }),
      );
      if (response.statusCode == 200) {
        print('Camera added successfully');
      } else {
        print('Failed to add camera: ${response.body}');
      }
    } catch (e) {
      print('Error adding camera: $e');
    }
  }

  // 카메라 삭제 메서드
  void deleteCamera(int index) {
    if (index >= 0 && index < _rtspUrls.length) {
      // 서버에 카메라 삭제 요청
      deleteCameraFromDatabase(index + 1);
      _rtspUrls.removeAt(index);
      notifyListeners();
    }
  }

  void deleteCameraFromDatabase(int cameraNumber) async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/delete_camera/$cameraNumber';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Camera deleted from database');
      } else {
        print('Failed to delete camera: ${response.body}');
      }
    } catch (e) {
      print('Error deleting camera: $e');
    }
  }
}
