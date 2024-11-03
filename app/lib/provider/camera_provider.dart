import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CameraProvider extends ChangeNotifier {
  final List<String> _rtspUrls = [];
  final List<int> _cameraNumbers = [];
  int _nextCameraNumber = 1;
  final Map<int, Map<String, dynamic>> _detectionStatus = {};

  List<String> get rtspUrls => _rtspUrls;
  List<int> get cameraNumbers => _cameraNumbers;
  Map<int, Map<String, dynamic>> get detectionStatus => _detectionStatus;

  CameraProvider() {
    _loadDetectionStatus();
  }

  Future<void> _loadDetectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (int cameraNumber in _cameraNumbers) {
      _detectionStatus[cameraNumber] = {
        'Fall': prefs.getBool('camera${cameraNumber}_fallDetection') ?? false,
        'Fire': prefs.getBool('camera${cameraNumber}_fireDetection') ?? false,
        'Move':
            prefs.getBool('camera${cameraNumber}_movementDetection') ?? false,
        'Range': prefs.getBool('camera${cameraNumber}_detectionRange') ?? false,
        'roi': {
          'x1': prefs.getInt('camera${cameraNumber}_roi_x1') ?? 0,
          'y1': prefs.getInt('camera${cameraNumber}_roi_y1') ?? 0,
          'x2': prefs.getInt('camera${cameraNumber}_roi_x2') ?? 1920,
          'y2': prefs.getInt('camera${cameraNumber}_roi_y2') ?? 1080,
        }
      };
    }
    notifyListeners();
  }

  Future<void> saveAllDetectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _detectionStatus.entries) {
      int cameraNumber = entry.key;
      Map<String, dynamic> statuses = entry.value;

      // 기본 상태 저장
      await prefs.setBool(
          'camera${cameraNumber}_fallDetection', statuses['Fall'] ?? false);
      await prefs.setBool(
          'camera${cameraNumber}_fireDetection', statuses['Fire'] ?? false);
      await prefs.setBool(
          'camera${cameraNumber}_movementDetection', statuses['Move'] ?? false);
      await prefs.setBool(
          'camera${cameraNumber}_detectionRange', statuses['Range'] ?? false);

      // ROI 값 저장
      Map<String, int> roi =
          statuses['roi'] ?? {'x1': 0, 'y1': 0, 'x2': 1920, 'y2': 1080};
      await prefs.setInt('camera${cameraNumber}_roi_x1', roi['x1'] ?? 0);
      await prefs.setInt('camera${cameraNumber}_roi_y1', roi['y1'] ?? 0);
      await prefs.setInt('camera${cameraNumber}_roi_x2', roi['x2'] ?? 1920);
      await prefs.setInt('camera${cameraNumber}_roi_y2', roi['y2'] ?? 1080);
    }
  }

  Future<void> initializeCameraNumbers() async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/get_max_camera_number';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _nextCameraNumber = (data['max_camera_number'] ?? 0) + 1;
        notifyListeners();
      } else {
        print('Failed to get max camera number: ${response.body}');
      }
    } catch (e) {
      print('Error fetching max camera number: $e');
    }
  }

  Future<void> addCamera(String rtspUrl, String userId) async {
    int cameraNumber = _nextCameraNumber;
    _nextCameraNumber++;

    _rtspUrls.add(rtspUrl);
    _cameraNumbers.add(cameraNumber);
    _detectionStatus[cameraNumber] = {
      'Fall': false,
      'Fire': false,
      'Move': false,
      'Range': false,
      'roi': {'x1': 0, 'y1': 0, 'x2': 1920, 'y2': 1080},
    };
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

  void addCameraLocally(
    String rtspUrl,
    int cameraNumber, {
    bool fallDetection = false,
    bool fireDetection = false,
    bool movementDetection = false,
    bool rangeDetection = false,
    Map<String, int>? roi = const {'x1': 0, 'y1': 0, 'x2': 1920, 'y2': 1080},
  }) {
    _rtspUrls.add(rtspUrl);
    _cameraNumbers.add(cameraNumber);
    _detectionStatus[cameraNumber] = {
      'Fall': fallDetection,
      'Fire': fireDetection,
      'Move': movementDetection,
      'Range': rangeDetection,
      'roi': roi,
    };
    notifyListeners();
  }

  bool? getDetectionStatus(int cameraNumber, String statusKey) {
    return _detectionStatus[cameraNumber]?[statusKey] as bool?;
  }

  void deleteCamera(int cameraNumber) {
    int index = _cameraNumbers.indexOf(cameraNumber);
    if (index != -1) {
      deleteCameraFromDatabase(cameraNumber);

      _rtspUrls.removeAt(index);
      _cameraNumbers.removeAt(index);
      _detectionStatus.remove(cameraNumber);
      notifyListeners();
    } else {
      print("Camera with number $cameraNumber not found.");
    }
  }

  Future<void> deleteCameraFromDatabase(int cameraNumber) async {
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

  void updateDetectionStatus(
    int cameraNumber,
    String detectionType,
    bool status,
  ) async {
    if (_detectionStatus[cameraNumber] != null) {
      _detectionStatus[cameraNumber]![detectionType] = status;
      await _saveDetectionStatus(cameraNumber);
      notifyListeners();
    }
  }

  String getRtspUrlByCameraNumber(int cameraNumber) {
    int index = _cameraNumbers.indexOf(cameraNumber);
    if (index != -1) {
      return _rtspUrls[index];
    } else {
      throw Exception("Invalid camera number: $cameraNumber");
    }
  }

  Future<void> _saveDetectionStatus(int cameraNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final statuses = _detectionStatus[cameraNumber];
    await prefs.setBool(
        'camera${cameraNumber}_fallDetection', statuses?['Fall'] ?? false);
    await prefs.setBool(
        'camera${cameraNumber}_fireDetection', statuses?['Fire'] ?? false);
    await prefs.setBool(
        'camera${cameraNumber}_movementDetection', statuses?['Move'] ?? false);
    await prefs.setBool(
        'camera${cameraNumber}_detectionRange', statuses?['Range'] ?? false);

    Map<String, int> roi =
        statuses?['roi'] ?? {'x1': 0, 'y1': 0, 'x2': 1920, 'y2': 1080};
    await prefs.setInt('camera${cameraNumber}_roi_x1', roi['x1'] ?? 0);
    await prefs.setInt('camera${cameraNumber}_roi_y1', roi['y1'] ?? 0);
    await prefs.setInt('camera${cameraNumber}_roi_x2', roi['x2'] ?? 1920);
    await prefs.setInt('camera${cameraNumber}_roi_y2', roi['y2'] ?? 1080);
  }
}
