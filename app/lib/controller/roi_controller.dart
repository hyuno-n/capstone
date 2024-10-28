// roi_controller.dart
import 'package:flutter/material.dart';

// RoiController 위젯은 ROI(Region of Interest) 선택 도구로, 특정 영역을 드래그하여 선택하는 기능을 제공합니다.
class RoiController extends StatefulWidget {
  final double boxWidth; // 드래그 가능 영역의 너비
  final double boxHeight; // 드래그 가능 영역의 높이
  final Function(Rect?) onRoiUpdated; // ROI가 업데이트될 때 호출되는 콜백 함수

  const RoiController({
    super.key,
    required this.boxWidth,
    required this.boxHeight,
    required this.onRoiUpdated,
  });

  @override
  _RoiControllerState createState() => _RoiControllerState();
}

// _RoiControllerState는 ROI 드래그 동작을 관리합니다.
class _RoiControllerState extends State<RoiController> {
  Offset? startPosition; // 드래그 시작 위치
  Offset? currentPosition; // 드래그 현재 위치
  Rect? roiRect; // ROI 영역을 나타내는 사각형

  // 드래그 시작 시 호출되는 메서드
  void _onPanStart(DragStartDetails details) {
    setState(() {
      // 제한된 위치로 시작 위치를 설정
      startPosition = _getLimitedPosition(details.localPosition);
      currentPosition = startPosition;
    });
  }

  // 드래그 중일 때 호출되는 메서드
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // 현재 위치를 제한된 범위 내로 설정
      currentPosition = _getLimitedPosition(details.localPosition);
    });
  }

  // 드래그 종료 시 호출되는 메서드
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      // 드래그 시작 위치와 현재 위치로부터 사각형을 생성하여 ROI 영역으로 설정
      if (startPosition != null && currentPosition != null) {
        roiRect = Rect.fromPoints(startPosition!, currentPosition!);
        widget.onRoiUpdated(roiRect); // ROI 업데이트 콜백 호출
      }
    });

    // ROI 좌표를 콘솔에 출력
    if (roiRect != null) {
      print(
          'ROI 좌표: (${roiRect!.left}, ${roiRect!.top}, ${roiRect!.right}, ${roiRect!.bottom})');
    }
  }

  // 주어진 위치를 boxWidth와 boxHeight 범위 내로 제한하는 메서드
  Offset _getLimitedPosition(Offset position) {
    double x = position.dx.clamp(0.0, widget.boxWidth); // x축 제한
    double y = position.dy.clamp(0.0, widget.boxHeight); // y축 제한
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 드래그 시작, 업데이트, 종료 시 이벤트 연결
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.boxWidth, // 드래그 가능한 영역의 너비 설정
        height: widget.boxHeight, // 드래그 가능한 영역의 높이 설정
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0), // 검은 테두리
        ),
        child: CustomPaint(
          // ROI를 시각적으로 그리기 위한 커스텀 페인터 추가
          painter: RoiPainter(
            startPosition,
            currentPosition,
            widget.boxWidth,
            widget.boxHeight,
          ),
        ),
      ),
    );
  }
}

class RoiPainter extends CustomPainter {
  final Offset? startPosition; // 드래그 시작 위치
  final Offset? currentPosition; // 드래그 현재 위치
  final double boxWidth; // 페인터가 그릴 수 있는 영역의 너비
  final double boxHeight; // 페인터가 그릴 수 있는 영역의 높이
  final double strokeWidth = 2.0; // 사각형 테두리 두께

  RoiPainter(
      this.startPosition, this.currentPosition, this.boxWidth, this.boxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // ROI 영역을 위한 페인트 객체 설정
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5) // 반투명 빨간색
      ..style = PaintingStyle.stroke // 테두리만 그리도록 설정
      ..strokeWidth = strokeWidth; // 테두리 두께

    // 시작 위치와 현재 위치를 기반으로 사각형을 그립니다.
    if (startPosition != null && currentPosition != null) {
      // ROI 사각형이 경계 내에 있도록 설정
      Rect rect = Rect.fromPoints(
        _clampOffset(startPosition!),
        _clampOffset(currentPosition!),
      ).deflate(strokeWidth / 2); // strokeWidth로 경계 바깥으로 나가지 않도록 조정
      canvas.drawRect(rect, paint); // ROI 사각형을 캔버스에 그림
    }

    // ROI 영역 중앙에 교차선을 그리기 위한 페인트 객체 설정
    final crossPaint = Paint()
      ..color = Colors.grey // 회색
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 중앙 선을 그릴 때 경계를 벗어나지 않도록 값 조정
    double centerX = (boxWidth / 2).clamp(0.0, boxWidth - strokeWidth);
    double centerY = (boxHeight / 2).clamp(0.0, boxHeight - strokeWidth);

    // 캔버스에 세로와 가로 교차선 그리기 (strokeWidth 보정 적용)
    canvas.drawLine(
      Offset(centerX, strokeWidth / 2),
      Offset(centerX, boxHeight - strokeWidth), // 경계 내에 머무르도록 보정
      crossPaint,
    );
    canvas.drawLine(
      Offset(strokeWidth / 2, centerY),
      Offset(boxWidth - strokeWidth, centerY), // 경계 내에 머무르도록 보정
      crossPaint,
    );
  }

  // Offset 위치를 경계 내로 제한하는 메서드
  Offset _clampOffset(Offset offset) {
    // strokeWidth에 따른 제한으로 경계를 벗어나지 않도록 조정
    return Offset(
      offset.dx.clamp(strokeWidth, boxWidth - strokeWidth),
      offset.dy.clamp(strokeWidth, boxHeight - strokeWidth),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 항상 재페인팅하여 실시간 업데이트를 반영하도록 설정
  }
}
