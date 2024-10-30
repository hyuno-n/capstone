import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/controller/ai_fullscreen.dart';

class Streaming extends StatefulWidget {
  final bool showVolumeSlider;
  final String rtspUrl;
  final String cameraName;
  final VoidCallback? onVolumeToggle; // Volume toggle 콜백 추가
  final VoidCallback? onDelete; // 삭제 콜백 추가

  const Streaming({
    required this.showVolumeSlider,
    required this.rtspUrl,
    required this.cameraName,
    this.onVolumeToggle, // 콜백 추가
    this.onDelete, // 삭제 콜백 추가
    super.key,
  });

  @override
  _StreamingState createState() => _StreamingState();
}

class _StreamingState extends State<Streaming> {
  late VlcPlayerController vlcViewController;
  double _volume = 100.0;
  bool _isVolumeSliderVisible = false; // 슬라이더 가시성 상태

  @override
  void initState() {
    super.initState();
    vlcViewController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    vlcViewController.dispose();
    super.dispose();
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
    });
    vlcViewController.setVolume(volume.toInt());
    print("현재 볼륨: ${volume.toInt()}%"); // 볼륨 값 디버그 콘솔에 출력
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("삭제 확인"),
          content: const Text("이 카메라를 삭제하시겠습니까?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text("삭제"),
              onPressed: () {
                if (widget.onDelete != null) {
                  widget.onDelete!(); // 안전하게 호출
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 볼륨 슬라이더를 토글하는 메서드
  void _toggleVolumeSlider() {
    setState(() {
      _isVolumeSliderVisible = !_isVolumeSliderVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 250,
                child: VlcPlayer(
                  controller: vlcViewController,
                  aspectRatio: 16 / 9,
                  placeholder: const SizedBox(
                    height: 250.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              // 슬라이더
              if (_isVolumeSliderVisible)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -5, // 아이콘 위쪽에 표시되도록 위치 조정
                  child: Slider(
                    value: _volume, // 현재 볼륨
                    min: 0, // 최소값
                    max: 100, // 최대값
                    divisions: 100, // 0~100 구간을 100으로 나누기
                    label: "${_volume.toInt()}%", // 슬라이더 레이블 표시
                    onChanged: (double value) {
                      _setVolume(value);
                    },
                    activeColor: Colors.grey[400], // 슬라이더 활성 색상
                    inactiveColor: Colors.white54, // 슬라이더 비활성 색상
                  ),
                ),
            ],
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    widget.cameraName,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/icons/microphone.svg",
                    height: 20,
                  ),
                  onPressed: () {}, // Microphone toggle logic 추가 필요
                ),
                IconButton(
                  icon: SvgPicture.asset("assets/svg/icons/audio_on.svg"),
                  onPressed: () {
                    _toggleVolumeSlider(); // 볼륨 슬라이더 표시 토글
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                      "assets/svg/icons/delete_icon.svg"), // 삭제 아이콘 추가
                  onPressed: () {
                    _showDeleteConfirmationDialog(context); // 삭제 확인 다이얼로그 호출
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/icons/fullscreen.svg",
                    height: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenVideoPage(
                          //ai_fullscreen.dart 에서 가져옴
                          rtspUrl: widget.rtspUrl, // fullscreen에 사용할 rtspUrl
                        ),
                      ),
                    ).then((_) {
                      // UI가 사라지게 하는 처리
                      setState(() {
                        _isVolumeSliderVisible = false; // 슬라이더 숨기기
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
