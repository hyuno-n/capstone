import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  final List<String> _rtspUrls = [];

  List<String> get rtspUrls => _rtspUrls;

  void addCamera(String url) {
    _rtspUrls.add(url);
    notifyListeners(); // 추가 시 UI에 변경 사항 알림
  }

  void deleteCamera(int index) {
    if (index >= 0 && index < _rtspUrls.length) {
      _rtspUrls.removeAt(index);
      notifyListeners(); // 삭제 시 UI에 변경 사항 알림
    }
  }
}