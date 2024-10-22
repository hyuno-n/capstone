import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:home_protect/controller/app_controller.dart';
import 'package:home_protect/pages/ai_report_page.dart';
import 'package:home_protect/pages/log_page.dart';
import 'package:home_protect/pages/monitoring.dart';
import 'package:home_protect/pages/user_page.dart';

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
        return Container(); // 기본적으로 빈 컨테이너를 반환
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색을 하얀색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 그림자 색상
                spreadRadius: 1, // 그림자의 퍼짐 반경
                blurRadius: 5, // 그림자 블러 정도
                offset: const Offset(0, -2), // 그림자의 위치 (위쪽)
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white, // BottomNavigationBar의 배경색을 하얀색으로 설정
            type: BottomNavigationBarType.fixed,
            currentIndex: controller.currentIndex.value,
            selectedItemColor: Colors.black, // 선택된 아이템 글자색을 검정색으로 설정
            unselectedItemColor: Colors.black
                .withOpacity(0.6), // 선택되지 않은 아이템 글자색을 약간 투명한 검정색으로 설정
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: controller.changePageIndex,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svg/icons/video_off.svg"),
                activeIcon: SvgPicture.asset("assets/svg/icons/video_on.svg"),
                label: "모니터링",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svg/icons/report_off.svg"),
                activeIcon: SvgPicture.asset("assets/svg/icons/report_on.svg"),
                label: "AI 리포트",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svg/icons/alarm_off.svg"),
                activeIcon: SvgPicture.asset("assets/svg/icons/alarm_on.svg"),
                label: "로그 확인",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svg/icons/user_off.svg"),
                activeIcon: SvgPicture.asset(
                  "assets/svg/icons/user_on.svg",
                  width: 22,
                ),
                label: "마이 페이지",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
