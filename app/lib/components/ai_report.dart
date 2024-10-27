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
  bool isDetectionRangeOn = false; // 감지 범위 스위치 추가
  Offset? startPosition; // 드래그 시작 위치
  Offset? currentPosition; // 드래그 현재 위치
  Rect? roiRect; // 최종 ROI 네모 박스 좌표
  double boxWidth = 400; // 4:3 비율의 네모 박스 너비
  double boxHeight = 250; // 수직 길이 줄임
  late AnimationController _controller; // 애니메이션 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadSwitchStates(); // 저장된 스위치 상태를 로드
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // 애니메이션 시간
      vsync: this,
    );
  }

  // 스위치 상태를 SharedPreferences에서 불러오는 함수
  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFallDetectionOn = prefs.getBool('fallDetection') ?? false;
      isFireDetectionOn = prefs.getBool('fireDetection') ?? false;
      isDetectionRangeOn = prefs.getBool('detectionRange') ?? false;
      if (isDetectionRangeOn) {
        _controller.forward();
      }
    });
  }

  // 스위치 상태를 SharedPreferences에 저장하는 함수
  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  // 넘어짐 감지 스위치 변경
  void _onFallDetectionChanged(bool value) {
    setState(() {
      isFallDetectionOn = value;
      _saveSwitchState('fallDetection', value);
    });
    sendEventToFlask(
      'fall_detection',
      'user123',
      value ? 'activated' : 'deactivated', // 상태에 따라 전송
    );
  }

  // 화재 감지 스위치 변경
  void _onFireDetectionChanged(bool value) {
    setState(() {
      isFireDetectionOn = value;
      _saveSwitchState('fireDetection', value);
    });
    sendEventToFlask(
      'fire_detection',
      'user123',
      value ? 'activated' : 'deactivated', // 상태에 따라 전송
    );
  }

  // 감지 범위 스위치 변경
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

  // 위치가 검정 박스의 경계를 벗어나지 않도록 제한하는 함수
  Offset _getLimitedPosition(Offset position) {
    double x = position.dx.clamp(0.0, 350.0);
    double y = position.dy.clamp(0.0, boxHeight);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              height: 0.3,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
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
                              border: Border.all(color: Colors.black, width: 2),
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
            const Expanded(child: SizedBox()),
          ],
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
