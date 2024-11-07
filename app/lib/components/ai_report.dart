import 'dart:math';
import 'package:app/components/loading_indicator.dart';
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

class _AiReportState extends State<AiReport> with TickerProviderStateMixin {
  Future<void>? _cameraInitialization;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _cameraInitialization = _initializeSettings();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  Future<void> _initializeSettings() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    await cameraProvider.initializeCameraNumbers();
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
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
        (setting == 'Fall' ||
            setting == 'Fire' ||
            setting == 'Move' ||
            setting == 'Smoke')) {
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
    } else if (setting == 'Smoke') {
      message = "연기 감지를 활성화하시겠습니까?";
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
      cameraSettings?['Smoke'] ?? false,
      currentUserId,
      roiProvider.getRoiValues(),
      cameraNumber,
    );
  }

  Widget _buildCameraSettings(int cameraIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 13.0),
          child: Text(
            'Camera ${cameraIndex + 1}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        SizedBox(height: 10),
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
                setting: 'Smoke', // Smoke 추가
                title: 'Smoke',
                icon: 'assets/images/setting_smoke.png', // Smoke 아이콘
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
        color:
            value ? Colors.grey[900] : const Color.fromARGB(255, 228, 224, 225),
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.only(right: 16),
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
                      fontSize: (setting == 'Range' || setting == 'Smoke')
                          ? 17
                          : 20.0,
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
            return Center(child: LoadingIndicator()); // 로딩 중일 때 표시
          } else if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          } else {
            return Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                if (cameraProvider.rtspUrls.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlideTransition(
                          position: _animation,
                          child: Image.asset(
                            'assets/images/no_camera_icon.png',
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Text(
                          '카메라를 추가해주세요',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8.0), // 둥근 테두리 설정
                                child: Image.asset(
                                  'assets/images/ai_report_benner.jpg',
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 23,
                              top: 25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '원하는 감지 항목을',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "선택해주세요 :)",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
