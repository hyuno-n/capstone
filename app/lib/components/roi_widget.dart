import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/roi_provider.dart';
import 'package:app/controller/roi_controller.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart'; // VlcPlayer 패키지 추가

class RoiWidget extends StatefulWidget {
  const RoiWidget({super.key});

  @override
  _RoiWidgetState createState() => _RoiWidgetState();
}

class _RoiWidgetState extends State<RoiWidget> {
  int? _selectedCameraIndex;
  late VlcPlayerController _vlcViewController;

  @override
  void initState() {
    super.initState();
    // 초기화 시 VlcPlayerController 설정
    _vlcViewController = VlcPlayerController.network(
      '', // 기본 URL을 비워둡니다.
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
            // 카메라 선택 메뉴 버튼
            Consumer<CameraProvider>(builder: (context, cameraProvider, child) {
              return PopupMenuButton<int>(
                // PopupMenuButton의 onSelected 내에서
                onSelected: (index) {
                  setState(() {
                    _selectedCameraIndex = index;
                    String selectedUrl = cameraProvider.rtspUrls[index];
                    print("Selected Camera URL: $selectedUrl"); // URL 출력

                    // URL이 비어 있지 않은 경우에만 설정
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
                // 배경 스트리밍 영상
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
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),

                // ROI 설정 드로잉 영역
                SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: RoiController(
                    boxWidth: boxWidth,
                    boxHeight: boxHeight,
                    onRoiUpdated: (Rect? roi) {
                      Provider.of<RoiProvider>(context, listen: false)
                          .updateRoi(roi);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ROI 좌표 정보 표시
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
