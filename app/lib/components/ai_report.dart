import 'dart:math';
import 'package:app/components/roi_widget.dart';
import 'package:app/provider/roi_provider.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/server/detection_service.dart';
import 'package:app/controller/user_controller.dart';
import 'package:get/get.dart';

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport> {
  Future<void>? _cameraInitialization;

  @override
  void initState() {
    super.initState();
    _cameraInitialization = _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    await cameraProvider.initializeCameraNumbers();
  }

  Future<void> _saveSwitchState(
      int cameraNumber, String key, bool value) async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    cameraProvider.updateDetectionStatus(cameraNumber, key, value);
  }

  void _onSettingChanged(int cameraIndex, String setting, bool value) {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final cameraNumber = cameraProvider.cameraNumbers[cameraIndex];

    if (value &&
        (setting == 'Fall' || setting == 'Fire' || setting == 'Move')) {
      _showConfirmationDialog(cameraNumber, setting, value);
    } else if (setting == 'Range') {
      _onDetectionRangeChanged(cameraNumber, value);
    } else {
      setState(() {
        _saveSwitchState(cameraNumber, setting, value);
        _updateDetectionStates(cameraNumber);
      });
    }
  }

  void _onDetectionRangeChanged(int cameraNumber, bool value) {
    final roiProvider = Provider.of<RoiProvider>(context, listen: false);

    setState(() {
      _saveSwitchState(cameraNumber, 'Range', value);

      if (value) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => RoiWidget(
              selectedCameraIndex: cameraNumber,
              onRoiSelected: (roi) {
                Provider.of<RoiProvider>(context, listen: false).updateRoi(roi);
                _updateDetectionStates(cameraNumber);
              },
              onCompletion: (bool success) {
                _saveSwitchState(cameraNumber, 'Range', success);
              },
            ),
          ),
        );
      } else {
        roiProvider.resetRoi();
        _updateDetectionStates(cameraNumber);
      }
    });
  }

  void _showConfirmationDialog(int cameraNumber, String setting, bool value) {
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
                  _saveSwitchState(cameraNumber, setting, value);
                  _updateDetectionStates(cameraNumber);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDetectionStates(int cameraNumber) {
    final roiProvider = Provider.of<RoiProvider>(context, listen: false);
    final userController = Get.find<UserController>();
    final currentUserId = userController.getUserId;

    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final cameraSettings = cameraProvider.detectionStatus[cameraNumber];

    sendEventToFlask(
      cameraSettings?['Fall'] ?? false,
      cameraSettings?['Fire'] ?? false,
      cameraSettings?['Move'] ?? false,
      cameraSettings?['Range'] ?? false,
      currentUserId,
      roiProvider.getRoiValues(),
      cameraNumber,
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
    final cameraProvider = Provider.of<CameraProvider>(context);
    final cameraNumber = cameraProvider.cameraNumbers[cameraIndex];
    final cameraSettings = cameraProvider.detectionStatus[cameraNumber] ?? {};
    bool value = cameraSettings[setting] ?? false;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: value ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(icon,
              width: 52,
              height: 52,
              color: value ? Colors.white : Colors.black),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: (setting == 'Range') ? 18.4 : 20.0,
                      color: value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: pi / 2,
                child: CupertinoSwitch(
                  value: value,
                  onChanged: (bool newValue) {
                    _onSettingChanged(cameraIndex, setting, newValue);
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
      body: FutureBuilder(
        future: _cameraInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          } else {
            return Consumer<CameraProvider>(
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
                        ...List.generate(cameraProvider.rtspUrls.length,
                            (index) {
                          return _buildCameraSettings(index);
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
