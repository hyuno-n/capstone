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
    return Scaffold(
      body: Obx(() {
        switch (RouteName.values[controller.currentIndex.value]) {
          case RouteName.Monitoring:
            return const Monitoring();
          case RouteName.AI_report:
            return const AiReportPage();
          case RouteName.Detection_range:
            return const LogPage();
          case RouteName.User_page:
            return const User_page();
        }
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Colors.white, // 배경색을 하얀색으로 설정
            //boxShadow: [
            //  BoxShadow(
            //    color: Colors.grey.withOpacity(0.3), // 그림자 색상
            //    spreadRadius: 1, // 그림자의 퍼짐 반경
            //    blurRadius: 5, // 그림자 블러 정도
            //    offset: const Offset(0, -2), // 그림자의 위치 (위쪽)
            //  ),
            //],
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
            onTabChange: controller.changePageIndex,
            tabs: const [
              GButton(
                icon: Icons.videocam,
                iconSize: 34,
                text: '스트리밍',
                //icon: Icons.videocam_outlined,
                //iconColor: Colors.black.withOpacity(0.6),
                //text: '모니터링',
                //leading: SvgPicture.asset(
                //  controller.currentIndex.value == 0
                //      ? "assets/svg/icons/video_on.svg"
                //      : "assets/svg/icons/video_off.svg",
                //  width: 24,
                //),
              ),
              GButton(
                icon: Icons.featured_video,
                text: '감지 설정',
                //icon: Icons.report_outlined,
                //iconColor: Colors.black.withOpacity(0.6),
                //text: 'AI 리포트',
                //leading: SvgPicture.asset(
                //  controller.currentIndex.value == 1
                //      ? "assets/svg/icons/report_on.svg"
                //      : "assets/svg/icons/report_off.svg",
                //  width: 24,
                //),
              ),
              GButton(
                icon: Icons.featured_play_list,
                text: '영상 클립',
                //icon: Icons.alarm_outlined,
                //iconColor: Colors.black.withOpacity(0.6),
                //text: '로그 확인',
                //leading: SvgPicture.asset(
                //  controller.currentIndex.value == 2
                //      ? "assets/svg/icons/alarm_on.svg"
                //      : "assets/svg/icons/alarm_off.svg",
                //  width: 24,
                //),
              ),
              GButton(
                icon: Icons.account_circle,
                text: '마이 페이지',
                //icon: Icons.person_outline,
                //iconColor: Colors.black.withOpacity(0.6),
                //text: '마이 페이지',
                //leading: SvgPicture.asset(
                //  controller.currentIndex.value == 3
                //      ? "assets/svg/icons/user_on.svg"
                //      : "assets/svg/icons/user_off.svg",
                //  width: 22,
                //),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
