import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controller/log_controller.dart';
import 'package:app/components/log_list.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/components/loading_indicator.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> with TickerProviderStateMixin {
  late final LogController _logController;
  final UserController _userController = Get.find<UserController>();
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // CameraProvider를 가져와서 LogController 초기화
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    _logController = Get.put(LogController(cameraProvider));

    // 비디오 클립 가져오기
    _logController.fetchVideoClips(_userController.username.value);

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // 애니메이션 시간 설정
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.2), // 아래에서 살짝 나타남
      end: Offset.zero, // 최종 위치
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // 자연스러운 커브
    ));

    // 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정

      body: Obx(() {
        if (_logController.isLoading.value) {
          return Center(child: LoadingIndicator());
        } else if (_logController.videoClips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _animation,
                  child: Image.asset(
                    'assets/images/no_logg_icon.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  '저장된 영상 클립이 없습니다',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: LogList(videoclips: _logController.videoClips),
              ),
            ],
          );
        }
      }),
    );
  }
}
