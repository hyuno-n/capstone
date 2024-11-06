import 'package:app/controller/log_controller.dart';
import 'package:app/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controller/app_controller.dart';
import 'package:app/pages/ai_report_page.dart';
import 'package:app/pages/log_page.dart';
import 'package:app/pages/monitoring.dart';
import 'package:app/pages/user_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class App extends GetView<AppController> {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final logController = Get.find<LogController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            //boxShadow: [
            //  BoxShadow(
            //    color: Colors.grey.withOpacity(0.3),
            //    spreadRadius: 1,
            //    blurRadius: 5,
            //    offset: const Offset(0, 2),
            //  ),
            //],
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
                      icon: const Icon(Icons.notifications_none_outlined),
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
        return PageView(
          controller: pageController,
          onPageChanged: (index) {
            controller.currentIndex.value = index;
          },
          children: const [
            Monitoring(),
            AiReportPage(),
            LogPage(),
            User_page(),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black.withOpacity(0.6), // 비활성화된 아이템 색상
            activeColor: Colors.black, // 활성화된 아이템 색상
            tabBackgroundColor: Colors.grey[200]!, // 활성화된 탭 배경색
            gap: 8, // 아이콘과 텍스트 사이의 간격
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            selectedIndex: controller.currentIndex.value,
            onTabChange: (index) {
              controller.changePageIndex(index); // 선택된 인덱스 업데이트
              pageController.jumpToPage(index); // PageView 페이지 전환
            },
            tabs: const [
              GButton(
                icon: Icons.videocam,
                iconSize: 34,
                text: '스트리밍',
              ),
              GButton(
                icon: Icons.featured_video,
                text: '감지 설정',
              ),
              GButton(
                icon: Icons.featured_play_list,
                text: '영상 클립',
              ),
              GButton(
                icon: Icons.account_circle,
                text: '마이 페이지',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
