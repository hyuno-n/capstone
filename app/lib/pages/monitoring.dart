import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/components/drawer_widget.dart';
import 'package:app/components/video_widget.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  _MonitoringState createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
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
              "Video😘",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
      drawer: const DrawerWidget(),
      body: const Center(
        child: VideoWidget(),
      ),
    );
  }
}
