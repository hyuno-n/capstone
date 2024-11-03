import 'package:app/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controller/log_controller.dart';
import 'package:app/components/log_list.dart';
import 'package:app/controller/user_controller.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> with TickerProviderStateMixin {
  final LogController _logController = Get.put(LogController());
  final UserController _userController = Get.find<UserController>();
  final logController = Get.find<LogController>();
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _logController.fetchLogs(_userController.username.value);

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // 애니메이션 시간 설정
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset(0, 0.2), // 아래에서 살짝 나타남
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

  // 로그 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("로그 삭제"),
          content: const Text("로그를 전체 삭제하시겠습니까?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text("확인"),
              isDestructiveAction: true,
              onPressed: () {
                _logController.clearLogs(); // 확인을 누르면 로그 삭제
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/MVCCTV_main.png',
                  height: 180, // 이미지 높이 조정
                ),
              ],
            ),
            actions: [
              SizedBox(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      iconSize: 32,
                      onPressed: () {
                        logController
                            .resetNotificationCount(); // 알림 페이지로 가기 전에 알림 수 리셋
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                    Obx(() {
                      return logController.newNotificationCount.value > 0
                          ? Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 61, 61),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : Container(); // 알림이 없으면 빈 컨테이너 반환
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 5)
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (_logController.logs.isEmpty) {
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
                ), // 이미지와 텍스트 간격
                const Text(
                  '로그가 없습니다',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: LogList(logs: _logController.logs),
              ),
            ],
          );
        }
      }),
    );
  }
}
