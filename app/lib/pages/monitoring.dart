import 'package:app/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                spreadRadius: 0.5, // 그림자의 퍼짐 반경
                blurRadius: 7, // 그림자 블러 정도
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
                  alignment: Alignment.topRight, // 빨간 점의 위치 조정
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      iconSize: 32,
                      onPressed: () {
                        // NotificationPage로 이동
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      }, // 다이얼로그를 호출하도록 수정
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 9, // 빨간 점의 너비
                        height: 9, // 빨간 점의 높이
                        decoration: BoxDecoration(
                          color:
                              const Color.fromARGB(255, 255, 61, 61), // 빨간 점 색상
                          shape: BoxShape.circle, // 원형으로 설정
                        ),
                      ),
                    ),
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
        child: VideoWidget(),
      ),
    );
  }
}
