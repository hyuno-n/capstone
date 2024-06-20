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
          //break;
          case RouteName.AI_report:
            return const AiReportPage();
          //break;
          case RouteName.Detection_range:
            return const LogPage();
          //break;
          case RouteName.User_page:
            return const User_page();
          //break;
        }
        //return Container();
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          selectedItemColor: const Color.fromARGB(255, 196, 28, 202),
          showSelectedLabels: true,
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
    );
  }
}
