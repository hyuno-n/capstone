import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/roi_provider.dart';
import 'package:app/controller/roi_controller.dart';

class RoiWidget extends StatefulWidget {
  const RoiWidget({super.key});

  @override
  _RoiWidgetState createState() => _RoiWidgetState();
}

class _RoiWidgetState extends State<RoiWidget> {
  @override
  Widget build(BuildContext context) {
    double boxWidth = 360;
    double boxHeight = 270;

    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('ROI 설정'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          child: const Text('완료'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.activeBlue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RoiController(
                boxWidth: boxWidth,
                boxHeight: boxHeight,
                onRoiUpdated: (Rect? roi) {
                  // ROI 업데이트
                  Provider.of<RoiProvider>(context, listen: false)
                      .updateRoi(roi);
                },
              ),
            ),
            const SizedBox(height: 20),
            Consumer<RoiProvider>(
              builder: (context, roiProvider, child) {
                return roiProvider.roiRect != null
                    ? Column(
                        children: [
                          const Text(
                            'ROI 좌표',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Left: ${roiProvider.roiRect!.left.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Top: ${roiProvider.roiRect!.top.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Right: ${roiProvider.roiRect!.right.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Bottom: ${roiProvider.roiRect!.bottom.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text(
                        'ROI 설정되지 않음',
                        style: TextStyle(fontSize: 16),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
