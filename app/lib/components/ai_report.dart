import 'package:app/components/roi_widget.dart';
import 'package:app/provider/roi_provider.dart';
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
  bool isFallDetectionOn = false;
  bool isFireDetectionOn = false;
  bool isMovementDetectionOn = false;
  bool isDetectionRangeOn = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchStates();
  }

  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isFallDetectionOn = prefs.getBool('fallDetection') ?? false;
      isFireDetectionOn = prefs.getBool('fireDetection') ?? false;
      isMovementDetectionOn = prefs.getBool('movementDetection') ?? false;
      isDetectionRangeOn = prefs.getBool('detectionRange') ?? false;

      // ROI 감지 범위 스위치가 꺼져있다면 초기화
      if (!isDetectionRangeOn) {
        Provider.of<RoiProvider>(context, listen: false).resetRoi();
      }
    });
  }

  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  void _onFallDetectionChanged(bool value) {
    if (value) {
      _showConfirmationDialog(value, true);
    } else {
      setState(() {
        isFallDetectionOn = value;
        _saveSwitchState('fallDetection', value);
        _updateAllDetectionStates();
      });
    }
  }

  void _onFireDetectionChanged(bool value) {
    if (value) {
      _showConfirmationDialog(value, false);
    } else {
      setState(() {
        isFireDetectionOn = value;
        _saveSwitchState('fireDetection', value);
        _updateAllDetectionStates();
      });
    }
  }

  void _onMovementDetectionChanged(bool value) {
    if (value) {
      _showConfirmationDialog(value, null);
    } else {
      setState(() {
        isMovementDetectionOn = value;
        _saveSwitchState('movementDetection', value);
        _updateAllDetectionStates();
      });
    }
  }

  void _showConfirmationDialog(bool value, bool? isFallOrFire) {
    String message;
    if (isFallOrFire == true) {
      message = "넘어짐 감지를 활성화하시겠습니까?";
    } else if (isFallOrFire == false) {
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
                  if (isFallOrFire == true) {
                    isFallDetectionOn = true;
                    _saveSwitchState('fallDetection', true);
                  } else if (isFallOrFire == false) {
                    isFireDetectionOn = true;
                    _saveSwitchState('fireDetection', true);
                  } else {
                    isMovementDetectionOn = true;
                    _saveSwitchState('movementDetection', true);
                  }
                  _updateAllDetectionStates();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateAllDetectionStates() {
    final roiProvider = Provider.of<RoiProvider>(context, listen: false);
    final roiValues = roiProvider.getRoiValues(); // ROI 값을 가져옴

    // 현재 로그인한 사용자 ID를 가져오기
    final userController =
        Get.find<UserController>(); // UserController 인스턴스 가져오기
    String currentUserId = userController.getUserId; // 사용자 ID 가져오기

    sendEventToFlask(
      isFallDetectionOn,
      isFireDetectionOn,
      isMovementDetectionOn,
      currentUserId, // 여기에 현재 로그인한 사용자 ID를 전달
      roiValues,
    );
  }

  void _onDetectionRangeChanged(bool value) {
    setState(() {
      isDetectionRangeOn = value;
      _saveSwitchState('detectionRange', value);

      // 감지 범위 스위치가 꺼질 때 ROI 좌표 초기화
      if (!value) {
        Provider.of<RoiProvider>(context, listen: false).resetRoi();
        _updateAllDetectionStates();
        print("ROI 좌표값이 초기화되었습니다.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 넘어짐 감지
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        isFallDetectionOn
                            ? 'assets/images/fall_detection_on.gif'
                            : 'assets/images/fall_detection.gif',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "넘어짐 감지",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: isFallDetectionOn,
                    onChanged: _onFallDetectionChanged,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 화재 감지
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        isFireDetectionOn
                            ? 'assets/images/fire_detection_on.gif'
                            : 'assets/images/fire_detection.gif',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "화재 감지",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: isFireDetectionOn,
                    onChanged: _onFireDetectionChanged,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 움직임 감지 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        isMovementDetectionOn
                            ? 'assets/images/movement_on.gif'
                            : 'assets/images/movement.gif',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "움직임 감지",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: isMovementDetectionOn,
                    onChanged: _onMovementDetectionChanged,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                height: 0.3,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),

              // 감지 범위 설정
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        isDetectionRangeOn
                            ? 'assets/images/range_detection_set_on.gif'
                            : 'assets/images/range_detection_set.gif',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "감지 범위 설정",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: isDetectionRangeOn,
                    onChanged: _onDetectionRangeChanged,
                  ),
                ],
              ),

              // ROI 설정하기 CupertinoButton 추가
              if (isDetectionRangeOn)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 3),
                            Image(
                              image:
                                  AssetImage('assets/images/resize_icon.gif'),
                              width: 42,
                              height: 42,
                            ),
                            SizedBox(width: 14),
                            Text(
                              "ROI 설정하기",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        Icon(
                          CupertinoIcons.forward,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => RoiWidget(
                          onRoiSelected: (roi) {
                            // ROI 값을 전달받아 저장하는 로직 추가
                            Provider.of<RoiProvider>(context, listen: false)
                                .updateRoi(roi);
                            _updateAllDetectionStates();
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
