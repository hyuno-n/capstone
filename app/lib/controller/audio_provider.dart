import 'package:flutter/material.dart';

class VideoVolumeProvider extends ChangeNotifier {
  double _volume = 50;

  double get volume => _volume;

  void setVolume(double newVolume) {
    _volume = newVolume;
    notifyListeners();
  }
}
