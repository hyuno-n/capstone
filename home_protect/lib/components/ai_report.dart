import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport> {
  bool isFallDetectionOn = false;
  bool isFireDetectionOn = false;
  Offset? startPosition; // 드래그 시작 위치
  Offset? currentPosition; // 드래그 현재 위치
  Rect? roiRect; // 최종 ROI 네모 박스 좌표
  double boxWidth = 400; // 4:3 비율의 네모 박스 너비
  double boxHeight = 250; // 수직 길이 줄임

  @override
  void initState() {
    super.initState();
    _loadSwitchStates(); // 저장된 스위치 상태를 로드
  }

  // 스위치 상태를 SharedPreferences에서 불러오는 함수
  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFallDetectionOn = prefs.getBool('fallDetection') ?? false;
      isFireDetectionOn = prefs.getBool('fireDetection') ?? false;
    });
  }

  // 스위치 상태를 SharedPreferences에 저장하는 함수
  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  // 드래그 시작 시
  void _onPanStart(DragStartDetails details) {
    setState(() {
      // 시작 좌표를 검정 박스 내로 제한
      startPosition = _getLimitedPosition(details.localPosition);
      currentPosition = startPosition; // 현재 위치도 시작 위치로 초기화
    });
  }

  // 드래그 중일 때
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // 현재 좌표를 검정 박스 내로 제한
      currentPosition = _getLimitedPosition(details.localPosition);
    });
  }

  // 드래그 끝날 때
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (startPosition != null && currentPosition != null) {
        // ROI 네모 박스 좌표 계산
        roiRect = Rect.fromPoints(startPosition!, currentPosition!);
      }
    });

    // ROI 좌표 출력
    if (roiRect != null) {
      print(
          'ROI 좌표: (${roiRect!.left}, ${roiRect!.top}, ${roiRect!.right}, ${roiRect!.bottom})');
    }
  }

  // 위치가 검정 박스의 경계를 벗어나지 않도록 제한하는 함수
  Offset _getLimitedPosition(Offset position) {
    // x좌표는 0에서 350.0까지 제한하여 오른쪽 경계 밖으로 안 나가게 설정
    double x = position.dx.clamp(0.0, 350.0); // 오른쪽 경계 제한
    double y = position.dy.clamp(0.0, boxHeight); // 위, 아래 경계 제한
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
            // 기존의 넘어짐 감지와 화재 감지 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "넘어짐 감지",
                  style: TextStyle(fontSize: 18),
                ),
                CupertinoSwitch(
                  value: isFallDetectionOn,
                  onChanged: (value) {
                    setState(() {
                      isFallDetectionOn = value;
                    });
                    _saveSwitchState('fallDetection', value); // 상태 저장
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "화재 감지",
                  style: TextStyle(fontSize: 18),
                ),
                CupertinoSwitch(
                  value: isFireDetectionOn,
                  onChanged: (value) {
                    setState(() {
                      isFireDetectionOn = value;
                    });
                    _saveSwitchState('fireDetection', value); // 상태 저장
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 경계선 추가
            Container(
              height: 1,
              color: Colors.black,
            ),
            const SizedBox(height: 20),

            // ROI 선택기능을 위한 GestureDetector 추가
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      // 4:3 비율의 드래그 영역을 나타낼 검정 박스
                      Container(
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                      // 드래그로 선택한 ROI 네모 박스 그리기
                      if (startPosition != null && currentPosition != null)
                        CustomPaint(
                          painter: RoiPainter(startPosition!, currentPosition!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ROI 영역을 그리기 위한 CustomPainter 클래스
class RoiPainter extends CustomPainter {
  final Offset startPosition;
  final Offset currentPosition;

  RoiPainter(this.startPosition, this.currentPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 드래그로 그린 네모 박스 그리기
    Rect rect = Rect.fromPoints(startPosition, currentPosition);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
