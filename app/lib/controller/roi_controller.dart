import 'package:flutter/material.dart';

class RoiController extends StatefulWidget {
  final double boxWidth;
  final double boxHeight;
  final Function(Rect?) onRoiUpdated;

  const RoiController({
    super.key,
    required this.boxWidth,
    required this.boxHeight,
    required this.onRoiUpdated,
  });

  @override
  _RoiControllerState createState() => _RoiControllerState();
}

class _RoiControllerState extends State<RoiController> {
  Offset? startPosition;
  Offset? currentPosition;
  Rect? roiRect;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      startPosition = _getLimitedPosition(details.localPosition);
      currentPosition = startPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentPosition = _getLimitedPosition(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (startPosition != null && currentPosition != null) {
        // startPosition과 currentPosition 좌표를 정수로 반올림
        final roundedStartPosition = Offset(
          startPosition!.dx.toInt().toDouble(),
          startPosition!.dy.toInt().toDouble(),
        );
        final roundedCurrentPosition = Offset(
          currentPosition!.dx.toInt().toDouble(),
          currentPosition!.dy.toInt().toDouble(),
        );

        roiRect = Rect.fromPoints(roundedStartPosition, roundedCurrentPosition);

        // 1920x1080 해상도로 변환 후 정수로 변환
        final convertedRoiRect = Rect.fromLTRB(
          (roiRect!.left / widget.boxWidth * 1920).toInt().toDouble(),
          (roiRect!.top / widget.boxHeight * 1080).toInt().toDouble(),
          (roiRect!.right / widget.boxWidth * 1920).toInt().toDouble(),
          (roiRect!.bottom / widget.boxHeight * 1080).toInt().toDouble(),
        );

        widget.onRoiUpdated(convertedRoiRect); // 변환된 좌표로 콜백 호출
      }
    });
  }

  Offset _getLimitedPosition(Offset position) {
    double x = position.dx.clamp(0.0, widget.boxWidth);
    double y = position.dy.clamp(0.0, widget.boxHeight);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.boxWidth,
        height: widget.boxHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0),
        ),
        child: CustomPaint(
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
  final Offset? startPosition;
  final Offset? currentPosition;
  final double boxWidth;
  final double boxHeight;
  final double strokeWidth = 2.0;

  RoiPainter(
      this.startPosition, this.currentPosition, this.boxWidth, this.boxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (startPosition != null && currentPosition != null) {
      Rect rect = Rect.fromPoints(
        _clampOffset(startPosition!),
        _clampOffset(currentPosition!),
      ).deflate(strokeWidth / 2);
      canvas.drawRect(rect, paint);
    }

    final crossPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double centerX = (boxWidth / 2).clamp(0.0, boxWidth - strokeWidth);
    double centerY = (boxHeight / 2).clamp(0.0, boxHeight - strokeWidth);

    canvas.drawLine(
      Offset(centerX, strokeWidth / 2),
      Offset(centerX, boxHeight - strokeWidth),
      crossPaint,
    );
    canvas.drawLine(
      Offset(strokeWidth / 2, centerY),
      Offset(boxWidth - strokeWidth, centerY),
      crossPaint,
    );
  }

  Offset _clampOffset(Offset offset) {
    return Offset(
      offset.dx.clamp(strokeWidth, boxWidth - strokeWidth),
      offset.dy.clamp(strokeWidth, boxHeight - strokeWidth),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
