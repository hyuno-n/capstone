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

  Map<String, dynamic> getRoiValues() {
    return {
      'roi_x1': _roiRect?.left.round() ?? 0,
      'roi_y1': _roiRect?.top.round() ?? 0,
      'roi_x2': _roiRect?.right.round() ?? 0,
      'roi_y2': _roiRect?.bottom.round() ?? 0,
    };
  }
}
