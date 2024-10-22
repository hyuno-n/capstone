import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      isDetectionRangeOn =
          prefs.getBool('detectionRange') ?? false; // 감지 범위 스위치 상태 로드
      if (isDetectionRangeOn) {
        _controller.forward(); // 감지 범위가 켜져 있으면 애니메이션 진행
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
    if (value) {
      _showConfirmationDialog(value, true); // 스위치가 켜질 때 다이얼로그 호출
    } else {
      setState(() {
        isFallDetectionOn = value;
        _saveSwitchState('fallDetection', value); // 상태 저장
      });
    }
  }

  // 화재 감지 스위치 변경
  void _onFireDetectionChanged(bool value) {
    if (value) {
      _showConfirmationDialog(value, false); // 스위치가 켜질 때 다이얼로그 호출
    } else {
      setState(() {
        isFireDetectionOn = value;
        _saveSwitchState('fireDetection', value); // 상태 저장
      });
    }
  }

  // 넘어짐 감지 활성화 확인 다이얼로그
  void _showConfirmationDialog(bool value, bool isFallDetection) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("알림"),
          content: Text(
              isFallDetection ? "넘어짐 감지를 활성화하시겠습니까?" : "화재 감지를 활성화하시겠습니까?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            CupertinoDialogAction(
              child: const Text("확인"),
              onPressed: () {
                setState(() {
                  if (isFallDetection) {
                    isFallDetectionOn = true; // 상태 업데이트
                    _saveSwitchState('fallDetection', true); // 상태 저장
                  } else {
                    isFireDetectionOn = true; // 상태 업데이트
                    _saveSwitchState('fireDetection', true); // 상태 저장
                  }
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  // 감지 범위 스위치 변경
  void _onDetectionRangeChanged(bool value) {
    setState(() {
      isDetectionRangeOn = value;
      if (isDetectionRangeOn) {
        _controller.forward(); // 스위치가 켜질 때 애니메이션 실행
      } else {
        _controller.reverse(); // 스위치가 꺼질 때 애니메이션 실행
      }
      _saveSwitchState('detectionRange', value); // 상태 저장
    });
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
            // 넘어짐 감지 텍스트 및 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      isFallDetectionOn
                          ? 'assets/images/fall_detection_on.gif' // 감지 상태에 따른 이미지
                          : 'assets/images/fall_detection.gif',
                      width: 50, // 아이콘 너비
                      height: 50, // 아이콘 높이
                    ),
                    const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격
                    const Text(
                      "넘어짐 감지",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: isFallDetectionOn,
                  onChanged: _onFallDetectionChanged, // 스위치 변경 시 다이얼로그 호출
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 화재 감지 텍스트 및 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      isFireDetectionOn
                          ? 'assets/images/fire_detection_on.gif' // 감지 상태에 따른 이미지
                          : 'assets/images/fire_detection.gif',
                      width: 50, // 아이콘 너비
                      height: 50, // 아이콘 높이
                    ),
                    const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격
                    const Text(
                      "화재 감지",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: isFireDetectionOn,
                  onChanged: _onFireDetectionChanged, // 스위치 변경 시 다이얼로그 호출
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 경계선 추가
            Container(
              height: 0.3,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),

            // 감지 범위 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      isDetectionRangeOn
                          ? 'assets/images/range_detection_set_on.gif' // 스위치가 켜졌을 때 아이콘
                          : 'assets/images/range_detection_set.gif', // 스위치가 꺼졌을 때 아이콘
                      width: 50, // 아이콘 너비
                      height: 50, // 아이콘 높이
                    ),
                    const SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
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
                  elevation: 4, // 그림자의 깊이 설정
                  shadowColor: Colors.black.withOpacity(0.2), // 그림자 색상 설정
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  child: Container(
                    height: 335, // 원하는 높이로 설정
                    decoration: BoxDecoration(
                      color: Colors.white, // 배경색을 하얀색으로 설정
                      border:
                          Border.all(color: Colors.grey, width: 1), // 회색 얇은 경계선
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20), // 위쪽 여백
                        const Text(
                          "ROI 설정",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10), // 텍스트와 박스 사이 여백
                        GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Container(
                            width: boxWidth,
                            height: boxHeight + 2, // ROI 박스 높이는 기존 유지
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  width: 2), // ROI 박스 경계선 설정
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

            // 추가적인 공간을 위해
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }
}

// ROI 영역을 그리기 위한 CustomPainter 클래스
class RoiPainter extends CustomPainter {
  final Offset? startPosition;
  final Offset? currentPosition;
  final double boxWidth;
  final double boxHeight;

  RoiPainter(
      this.startPosition, this.currentPosition, this.boxWidth, this.boxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // 드래그로 그린 네모 박스 그리기
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 드래그로 그린 네모 박스가 있을 경우 그리기
    if (startPosition != null && currentPosition != null) {
      Rect rect = Rect.fromPoints(startPosition!, currentPosition!);
      canvas.drawRect(rect, paint);
    }

    // 회색 십자가 선 그리기
    final crossPaint = Paint()
      ..color = Colors.grey // 회색으로 설정
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 검정 박스의 중앙에 십자가 그리기
    double centerX = boxWidth / 2;
    double centerY = boxHeight / 2;

    // 수직선: 왼쪽으로 이동
    canvas.drawLine(
        Offset(centerX - 25, 0), Offset(centerX - 25, boxHeight), crossPaint);
    // 수평선
    canvas.drawLine(Offset(0, centerY), Offset(boxWidth, centerY), crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 항상 리페인트 필요
  }
}
