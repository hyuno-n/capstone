import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_protect/components/ai_report.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';

// Ai report 페이지 App에서 -> 이 페이지로 넘겨옴 <Ai report main page>

class AiReportPage extends StatelessWidget {
  const AiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                spreadRadius: 1, // 그림자의 퍼짐 반경
                blurRadius: 5, // 그림자 블러 정도
                offset: const Offset(0, 2), // 그림자의 위치 (아래쪽)
              ),
            ],
          ),
          child: AppBar(
            elevation: 0, // AppBar의 기본 그림자 제거
            backgroundColor: Colors.transparent, // 투명하게 설정
            title: const Text(
              "AI Report",
              style: TextStyle(fontSize: 15),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: SvgPicture.asset("assets/svg/icons/menu_upbar.svg"),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: SvgPicture.asset("assets/svg/icons/alarm_upbar.svg"),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      drawer: const DrawerWidget(),
      endDrawer: const EndDrawerWidget(),
      body: const Center(
        child: AiReport(),
      ),
    );
  }
}
