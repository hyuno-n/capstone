import 'dart:math';
import 'package:app/components/roi_widget.dart';
import 'package:app/provider/roi_provider.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/server/detection_service.dart';
import 'package:app/controller/user_controller.dart';
import 'package:get/get.dart';

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport> {
  // 카메라별 설정 상태 리스트
  List<Map<String, bool>> cameraSettings = [];

  @override
  void initState() {
    super.initState();
    _loadSwitchStates();
  }

  // 카메라별 설정 상태 로드
  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    final cameraCount =
        Provider.of<CameraProvider>(context, listen: false).rtspUrls.length;

    setState(() {
      cameraSettings = List.generate(cameraCount, (index) {
        return {
          'Fall': prefs.getBool('camera${index + 1}_fallDetection') ?? false,
          'Fire': prefs.getBool('camera${index + 1}_fireDetection') ?? false,
          'Move':
              prefs.getBool('camera${index + 1}_movementDetection') ?? false,
          'Range': prefs.getBool('camera${index + 1}_detectionRange') ?? false,
        };
      });
    });
  }

  Future<void> _saveSwitchState(int cameraIndex, String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('camera${cameraIndex + 1}_$key', value);
  }

  void _onSettingChanged(int cameraIndex, String setting, bool value) {
    // Fall, Fire, Move 설정 변경 시 다이얼로그 표시
    if (value &&
        (setting == 'Fall' || setting == 'Fire' || setting == 'Move')) {
      _showConfirmationDialog(cameraIndex, setting, value);
    } else if (setting == 'Range') {
      _onDetectionRangeChanged(cameraIndex, value);
    } else {
      // 직접 설정 상태 업데이트
      setState(() {
        cameraSettings[cameraIndex][setting] = value;
        _saveSwitchState(cameraIndex, setting, value);
        _updateDetectionStates(cameraIndex);

        // 디버그 콘솔에 카메라 번호와 설정 변경 상태 출력
        if (value) {
          print("Camera${cameraIndex + 1}번 $setting on");
        } else {
          print("Camera${cameraIndex + 1}번 $setting off");
        }
      });
    }
  }

  void _onDetectionRangeChanged(int cameraIndex, bool value) {
    setState(() {
      cameraSettings[cameraIndex]['Range'] = value;
      _saveSwitchState(cameraIndex, 'Range', value);

      // 감지 범위 설정이 켜질 경우 바로 RoiWidget으로 이동
      if (value) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => RoiWidget(
              selectedCameraIndex: cameraIndex, // 선택한 카메라 인덱스 전달
              onRoiSelected: (roi) {
                Provider.of<RoiProvider>(context, listen: false).updateRoi(roi);
                _updateDetectionStates(cameraIndex);
              },
              onCompletion: (bool success) {
                setState(() {
                  cameraSettings[cameraIndex]['Range'] = success;
                  _saveSwitchState(cameraIndex, 'Range', success);
                });
              },
            ),
          ),
        );
      } else {
        Provider.of<RoiProvider>(context, listen: false).resetRoi();
        _updateDetectionStates(cameraIndex);
      }
    });
  }

  void _showConfirmationDialog(int cameraIndex, String setting, bool value) {
    String message;
    if (setting == 'Fall') {
      message = "넘어짐 감지를 활성화하시겠습니까?";
    } else if (setting == 'Fire') {
      message = "화재 감지를 활성화하시겠습니까?";
    } else {
      message = "움직임 감지를 활성화하시겠습니까?";
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("알림"),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text("확인"),
              onPressed: () {
                setState(() {
                  cameraSettings[cameraIndex][setting] = value;
                  _saveSwitchState(cameraIndex, setting, value);
                  _updateDetectionStates(cameraIndex);
                  // 디버그 콘솔에 카메라 번호와 설정 변경 상태 출력
                  print("Camera${cameraIndex + 1}번 $setting on");
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDetectionStates(int cameraIndex) {
    final roiProvider = Provider.of<RoiProvider>(context, listen: false);
    final userController = Get.find<UserController>();
    final currentUserId = userController.getUserId;

    // 카메라별 설정 상태 업데이트 로직
    sendEventToFlask(
      cameraSettings[cameraIndex]['Fall']!,
      cameraSettings[cameraIndex]['Fire']!,
      cameraSettings[cameraIndex]['Move']!,
      cameraSettings[cameraIndex]['Range']!,
      currentUserId,
      roiProvider.getRoiValues(),
    );
  }

  Widget _buildCameraSettings(int cameraIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Camera ${cameraIndex + 1}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDetectionBox(
                cameraIndex: cameraIndex,
                setting: 'Fall',
                title: 'Fall',
                icon: 'assets/images/setting_fall.png',
              ),
              _buildDetectionBox(
                cameraIndex: cameraIndex,
                setting: 'Fire',
                title: 'Fire',
                icon: 'assets/images/setting_fire.png',
              ),
              _buildDetectionBox(
                cameraIndex: cameraIndex,
                setting: 'Move',
                title: 'Move',
                icon: 'assets/images/setting_move.png',
              ),
              _buildDetectionBox(
                cameraIndex: cameraIndex,
                setting: 'Range',
                title: 'Range',
                icon: 'assets/images/setting_range.png',
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildDetectionBox({
    required int cameraIndex,
    required String setting,
    required String title,
    required String icon,
  }) {
    double fontSize = (setting == 'Range') ? 18.4 : 20.0; // Range의 폰트 크기 조정
    return Container(
      width: 140,
      decoration: BoxDecoration(
          color: cameraSettings[cameraIndex][setting] ?? false
              ? Colors.grey[900]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(icon,
              width: 52,
              height: 52,
              color: cameraSettings[cameraIndex][setting]!
                  ? Colors.white
                  : Colors.black),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: cameraSettings[cameraIndex][setting]!
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              Transform.rotate(
                angle: pi / 2,
                child: CupertinoSwitch(
                  value: cameraSettings[cameraIndex][setting] ?? false,
                  onChanged: (bool value) {
                    _onSettingChanged(cameraIndex, setting, value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Welcome Setting,'),
                  Text("PICK CAMERA", style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 20),
                  ...List.generate(cameraProvider.rtspUrls.length, (index) {
                    if (cameraSettings.length <
                        cameraProvider.rtspUrls.length) {
                      cameraSettings.add({
                        'Fall': false,
                        'Fire': false,
                        'Move': false,
                        'Range': false,
                      });
                    }
                    return _buildCameraSettings(index);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
