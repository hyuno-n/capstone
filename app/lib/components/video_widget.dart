import 'package:app/usePage/adPage_1.dart';
import 'package:app/usePage/adPage_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final PageController _controller = PageController();
  int _currentPage = 0; // 현재 페이지 인덱스를 추적하는 변수

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round(); // 페이지 변경 시 인덱스 업데이트
      });
    });
  }

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
      height: 140,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 61, 61, 61),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white54,
              ),
              iconSize: 40,
              onPressed: () {
                _showCupertinoDialog(context);
              },
            ),
            const SizedBox(
              height: 7,
            ),
            const Text(
              "카메라를 등록하세요.",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return ListView(
      children: [
        // 광고 스타일의 컨테이너
        Stack(
          children: [
            Container(
              height: 100,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: PageView(
                controller: _controller,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page; // 페이지 변경 시 인덱스 업데이트
                  });
                },
                children: const [
                  AdPage_1(),
                  AdPage_2(),
                ],
              ),
            ),
            // 오른쪽 아래에 페이지 번호를 표시하는 위젯
            Positioned(
              right: 17,
              bottom: 17,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / 2', // 총 페이지 수를 함께 표시
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),

        // 카메라 목록과 추가 버튼
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
