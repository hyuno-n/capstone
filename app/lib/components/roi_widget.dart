import 'package:app/provider/roi_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:app/controller/roi_controller.dart';

class RoiWidget extends StatefulWidget {
  final Function(Rect) onRoiSelected; // ROI 선택 시 호출될 콜백 추가

  const RoiWidget({super.key, required this.onRoiSelected});

  @override
  _RoiWidgetState createState() => _RoiWidgetState();
}

class _RoiWidgetState extends State<RoiWidget> {
  int? _selectedCameraIndex;
  late VlcPlayerController _vlcViewController;
  Rect? _tempRoi; // 임시 ROI 저장 변수

  @override
  void initState() {
    super.initState();
    _vlcViewController = VlcPlayerController.network(
      '',
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    super.dispose();
  }

  void _setCameraUrl(String url) {
    _vlcViewController.setMediaFromNetwork(url);
  }

  void _saveRoi() {
    if (_tempRoi != null) {
      widget.onRoiSelected(_tempRoi!); // ROI 값을 AiReport에 전달
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
        middle: const Text('ROI 설정'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          child: const Text('완료'),
          onPressed: () {
            _saveRoi(); // ROI 저장 및 전달
            Navigator.pop(context);
          },
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 카메라 선택 메뉴 버튼
            Consumer<CameraProvider>(builder: (context, cameraProvider, child) {
              return PopupMenuButton<int>(
                onSelected: (index) {
                  setState(() {
                    _selectedCameraIndex = index;
                    String selectedUrl = cameraProvider.rtspUrls[index];

                    if (selectedUrl.isNotEmpty) {
                      _setCameraUrl(selectedUrl);
                    } else {
                      print("Error: Provided URL is empty.");
                    }
                  });
                },
                icon: const Icon(Icons.camera_alt, color: Colors.blue),
                itemBuilder: (BuildContext context) {
                  return List.generate(
                    cameraProvider.rtspUrls.length,
                    (index) => PopupMenuItem<int>(
                      value: index,
                      child: Text('Camera ${index + 1}'),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 20),

            // 배경에 스트리밍 영상과 ROI 설정 겹치기
            Stack(
              children: [
                if (_selectedCameraIndex != null)
                  Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: CupertinoColors.activeBlue, width: 2),
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
                      _tempRoi = roi; // 임시 ROI 값 저장
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
                        const Text('ROI 좌표', style: TextStyle(fontSize: 16)),
                        Text(
                            'Left: ${roiProvider.roiRect!.left.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            'Top: ${roiProvider.roiRect!.top.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            'Right: ${roiProvider.roiRect!.right.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            'Bottom: ${roiProvider.roiRect!.bottom.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16)),
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
