import 'package:app/provider/roi_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:app/controller/roi_controller.dart';

class RoiWidget extends StatefulWidget {
  final Function(Rect) onRoiSelected;
  final Function(bool) onCompletion;
  final int selectedCameraIndex; // 선택된 카메라 인덱스 추가

  const RoiWidget({
    super.key,
    required this.onRoiSelected,
    required this.onCompletion,
    required this.selectedCameraIndex, // 인덱스 받기
  });

  @override
  _RoiWidgetState createState() => _RoiWidgetState();
}

class _RoiWidgetState extends State<RoiWidget> {
  late VlcPlayerController _vlcViewController;
  Rect? _tempRoi;

  @override
  void initState() {
    super.initState();
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    try {
      String selectedUrl =
          cameraProvider.getRtspUrlByCameraNumber(widget.selectedCameraIndex);

      _vlcViewController = VlcPlayerController.network(
        selectedUrl,
        options: VlcPlayerOptions(),
      );
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    super.dispose();
  }

  void _saveRoi() {
    if (_tempRoi != null) {
      widget.onRoiSelected(_tempRoi!);
      widget.onCompletion(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = 360;
    double boxHeight = 270;

    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            widget.onCompletion(false);
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            size: 24,
          ),
        ),
        middle: const Text('ROI 설정'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          child: const Text(
            '완료',
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _saveRoi();
            Navigator.pop(context);
          },
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: CupertinoColors.activeBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: VlcPlayer(
                    controller: _vlcViewController,
                    aspectRatio: 16 / 9,
                    placeholder: const SizedBox(
                      height: 250.0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: RoiController(
                    boxWidth: boxWidth,
                    boxHeight: boxHeight,
                    onRoiUpdated: (Rect? roi) {
                      _tempRoi = roi;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<RoiProvider>(builder: (context, roiProvider, child) {
              return roiProvider.roiRect != null
                  ? Column(
                      children: [
                        const Text('ROI 설정되지 않음',
                            style: TextStyle(fontSize: 16))
                      ],
                    )
                  : const Text('ROI 설정되지 않음', style: TextStyle(fontSize: 16));
            }),
          ],
        ),
      ),
    );
  }
}
