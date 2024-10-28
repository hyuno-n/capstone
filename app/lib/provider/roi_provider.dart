// roi_provider.dart
import 'package:flutter/material.dart';

class RoiProvider with ChangeNotifier {
  Rect? _roiRect;

  Rect? get roiRect => _roiRect;

  void updateRoi(Rect? newRect) {
    _roiRect = newRect;
    notifyListeners();
  }

  void resetRoi() {
    _roiRect = null;
    notifyListeners();
  }
}
