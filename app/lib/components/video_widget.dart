import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:app/controller/video_streaming.dart';
import 'package:provider/provider.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool _showVolumeSlider = false;
  final TextEditingController _textEditingController = TextEditingController();

  void _toggleVolumeSlider() {
    setState(() {
      _showVolumeSlider = !_showVolumeSlider;
    });
  }

  void _showCupertinoDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Add Camera"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("접속하고자 하는 카메라 주소를 적으세요."),
              CupertinoTextField(
                controller: _textEditingController,
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
                if (_textEditingController.text.isNotEmpty) {
                  Provider.of<CameraProvider>(context, listen: false)
                      .addCamera(_textEditingController.text);
                  _textEditingController.clear();
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCamera(int index) {
    Provider.of<CameraProvider>(context, listen: false).deleteCamera(index);
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
    final cameraProvider = Provider.of<CameraProvider>(context);

    return ListView(
      children: [
        for (int i = 0; i < cameraProvider.rtspUrls.length; i++)
          Streaming(
            key: ValueKey(cameraProvider.rtspUrls[i]), // 고유한 Key를 URL로 설정
            showVolumeSlider: _showVolumeSlider,
            rtspUrl: cameraProvider.rtspUrls[i],
            cameraName: 'Camera ${i + 1}',
            onVolumeToggle: _toggleVolumeSlider,
            onDelete: () => _deleteCamera(i),
          ),
        _plusVideo(),
      ],
    );
  }
}
