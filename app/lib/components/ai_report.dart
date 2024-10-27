import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/server/detection_service.dart';

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport>
    with SingleTickerProviderStateMixin {
  bool isFallDetectionOn = false;
  bool isFireDetectionOn = false;
  bool isMovementDetectionOn = false; // 움직임 감지 스위치 추가
  bool isDetectionRangeOn = false;
  Offset? startPosition;
  Offset? currentPosition;
  Rect? roiRect;
  double boxWidth = 400;
  double boxHeight = 250;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadSwitchStates();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFallDetectionOn = prefs.getBool('fallDetection') ?? false;
      isFireDetectionOn = prefs.getBool('fireDetection') ?? false;
      isMovementDetectionOn = prefs.getBool('movementDetection') ?? false;
      isDetectionRangeOn = prefs.getBool('detectionRange') ?? false;
      if (isDetectionRangeOn) {
        _controller.forward();
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
      _showConfirmationDialog(value, null); // 움직임 감지 다이얼로그 호출
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
                  _updateAllDetectionStates(); // 모든 감지 상태 전송
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
    sendEventToFlask(
      isFallDetectionOn,
      isFireDetectionOn,
      isMovementDetectionOn,
      'user123',
    );
  }

  void _onDetectionRangeChanged(bool value) {
    setState(() {
      isDetectionRangeOn = value;
      if (isDetectionRangeOn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _saveSwitchState('detectionRange', value);
    });
  }

  // 드래그 시작 시
  void _onPanStart(DragStartDetails details) {
    setState(() {
      startPosition = _getLimitedPosition(details.localPosition);
      currentPosition = startPosition;
    });
  }

  // 드래그 중일 때
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentPosition = _getLimitedPosition(details.localPosition);
    });
  }

  // 드래그 끝날 때
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (startPosition != null && currentPosition != null) {
        roiRect = Rect.fromPoints(startPosition!, currentPosition!);
      }
    });

    if (roiRect != null) {
      print(
          'ROI 좌표: (${roiRect!.left}, ${roiRect!.top}, ${roiRect!.right}, ${roiRect!.bottom})');
    }
  }

  // 위치가 박스를 벗어나지 않도록 제한하는 함수
  Offset _getLimitedPosition(Offset position) {
    double x = position.dx.clamp(0.0, boxWidth);
    double y = position.dy.clamp(0.0, boxHeight);
    return Offset(x, y);
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

              // ROI 설정 박스 애니메이션
              SizeTransition(
                sizeFactor: _controller,
                child: ClipRect(
                  child: Material(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 335,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "ROI 설정",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: Container(
                              width: boxWidth,
                              height: boxHeight + 2,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: CustomPaint(
                                painter: RoiPainter(
                                  startPosition,
                                  currentPosition,
                                  boxWidth,
                                  boxHeight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RoiPainter extends CustomPainter {
  final Offset? startPosition;
  final Offset? currentPosition;
  final double boxWidth;
  final double boxHeight;

  RoiPainter(
      this.startPosition, this.currentPosition, this.boxWidth, this.boxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (startPosition != null && currentPosition != null) {
      Rect rect = Rect.fromPoints(startPosition!, currentPosition!);
      canvas.drawRect(rect, paint);
    }

    final crossPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double centerX = boxWidth / 2;
    double centerY = boxHeight / 2;

    canvas.drawLine(
        Offset(centerX - 25, 0), Offset(centerX - 25, boxHeight), crossPaint);
    canvas.drawLine(Offset(0, centerY), Offset(boxWidth, centerY), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
