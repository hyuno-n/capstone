import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/controller/video_streaming.dart';

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
          title: const Text("카메라 추가"),
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
              child: const Text("돌아가기"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text("추가"),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  // 현재 로그인한 user_id 가져오기
                  String userId = Get.find<UserController>().getUserId;

                  // 카메라 추가
                  Provider.of<CameraProvider>(context, listen: false)
                      .addCamera(_textEditingController.text, userId);

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

  void _deleteCamera(int cameraNumber) {
    // 고유한 cameraNumber로 삭제 호출
    Provider.of<CameraProvider>(context, listen: false)
        .deleteCamera(cameraNumber);
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
            key: ValueKey(cameraProvider.rtspUrls[i]),
            showVolumeSlider: _showVolumeSlider,
            rtspUrl: cameraProvider.rtspUrls[i],
            cameraName: 'Camera ${i + 1}', // 화면에 보이는 순서대로 번호 부여
            onVolumeToggle: _toggleVolumeSlider,
            onDelete: () =>
                _deleteCamera(cameraProvider.cameraNumbers[i]), // 실제 고유 번호로 삭제
          ),
        _plusVideo(),
      ],
    );
  }
}
