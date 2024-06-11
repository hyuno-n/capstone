import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_protect/controller/video_streaming.dart';
import 'package:home_protect/controller/video_streaming_2.dart';
import 'package:home_protect/pages/fullscreen_video_page.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool _showVolumeSlider = false;
  String _selectedCamera = 'Camera 1'; // 초기 선택: Camera 1
  final TextEditingController _textEditingController =
      TextEditingController(); // TextEditingController를 추가합니다.

  void _toggleVolumeSlider() {
    setState(() {
      _showVolumeSlider = !_showVolumeSlider;
    });
  }

  void _onCameraSelected(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCamera = newValue;
      });
    }
  }

  void _showCupertinoDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Add Camera"),
          content: Column(
            children: [
              const Text("접속하고자 하는 카메라 주소를 적으세요."),
              CupertinoTextField(
                controller:
                    _textEditingController, // TextEditingController를 사용하여 TextField의 값을 관리합니다.
                placeholder: "rtsp://...",
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text("적용"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _thumbnail(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: _selectedCamera == 'Camera 1'
                ? Streaming(showVolumeSlider: _showVolumeSlider)
                : Streaming2(showVolumeSlider: _showVolumeSlider),
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
                  child: DropdownButton<String>(
                    value: _selectedCamera,
                    onChanged: _onCameraSelected,
                    items: <String>['Camera 1', 'Camera 2'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/svg/icons/microphone.svg",
                    height: 20,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: SvgPicture.asset("assets/svg/icons/audio_on.svg"),
                  onPressed: _toggleVolumeSlider,
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
                          rtspUrl: _selectedCamera == 'Camera 1'
                              ? "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
                              : "rtsp://210.99.70.120:1935/live/cctv001.stream",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plusVideo() {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 8.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: IconButton(
          icon: SvgPicture.asset("assets/svg/icons/plus_button.svg"),
          onPressed: () {
            _showCupertinoDialog(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _thumbnail(context),
        _plusVideo(),
      ],
    );
  }
}
