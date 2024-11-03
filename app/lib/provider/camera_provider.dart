import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraProvider extends ChangeNotifier {
  final List<String> _rtspUrls = [];
  final List<int> _cameraNumbers = []; // 각 카메라의 고유 번호를 저장하는 리스트
  int _nextCameraNumber = 1;

  List<String> get rtspUrls => _rtspUrls;
  List<int> get cameraNumbers => _cameraNumbers;

  Future<void> addCamera(String rtspUrl, String userId) async {
    int cameraNumber = _nextCameraNumber;
    _nextCameraNumber++;

    rtspUrls.add(rtspUrl);
    _cameraNumbers.add(cameraNumber);
    notifyListeners();

    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/add_camera';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'rtsp_url': rtspUrl,
          'camera_number': cameraNumber
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

  void addCameraLocally(String rtspUrl, int cameraNumber) {
    _rtspUrls.add(rtspUrl);
    _cameraNumbers.add(cameraNumber);
    notifyListeners();
  }

  // camera_number를 이용해 카메라 삭제 메서드
  void deleteCamera(int cameraNumber) {
    int index = _cameraNumbers.indexOf(cameraNumber); // cameraNumber로 인덱스 찾기
    if (index != -1) {
      deleteCameraFromDatabase(cameraNumber);

      // 로컬 리스트에서 해당 카메라 정보 제거
      _rtspUrls.removeAt(index);
      _cameraNumbers.removeAt(index);
      notifyListeners();
    } else {
      print("Camera with number $cameraNumber not found.");
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
