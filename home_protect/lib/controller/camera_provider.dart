import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  final List<String> _rtspUrls = [];

  List<String> get rtspUrls => _rtspUrls;

  void addCamera(String url) {
    _rtspUrls.add(url);
    notifyListeners(); // 상태 변경 알림
  }

  void deleteCamera(int index) {
    if (index >= 0 && index < _rtspUrls.length) {
      _rtspUrls.removeAt(index);
      notifyListeners(); // 상태 변경 알림
    }
  }
}
