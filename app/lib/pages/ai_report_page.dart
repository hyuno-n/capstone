import 'package:app/controller/log_controller.dart';
import 'package:app/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/components/ai_report.dart';
import 'package:get/get.dart';

// Ai report 페이지 App에서 -> 이 페이지로 넘겨옴 <Ai report main page>

class AiReportPage extends StatelessWidget {
  const AiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logController = Get.find<LogController>();
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), // 기본 높이 설정
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar 배경색을 흰색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 그림자 색상
                spreadRadius: 0.1, // 그림자의 퍼짐 반경
                blurRadius: 5, // 그림자 블러 정도
                offset: const Offset(0, 2), // 그림자의 위치 (아래쪽)
              ),
            ],
          ),
          child: AppBar(
            elevation: 0, // AppBar의 기본 그림자 제거
            backgroundColor: Colors.transparent, // 투명하게 설정
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
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 61, 61),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : Container(); // 알림이 없으면 빈 컨테이너 반환
                    }),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              )
            ],
          ),
        ),
      ),
      // endDrawer: const DrawerWidget(),
      body: const Center(
        child: AiReport(),
      ),
    );
  }
}
