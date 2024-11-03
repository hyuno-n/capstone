import 'package:app/controller/log_controller.dart';
import 'package:app/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/provider/camera_provider.dart'; // CameraProvider import 추가
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class User_page extends StatelessWidget {
  const User_page({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
    final cameraProvider =
        Provider.of<CameraProvider>(context); // CameraProvider 인스턴스 가져오기
    final logController = Get.find<LogController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 0.8,
                blurRadius: 5,
                offset: const Offset(0, 2),
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
                //const SizedBox(width: 3), // 이미지와 텍스트 사이에 간격 추가
                //const Text(
                //  "MVCCTV",
                //  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                //),
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
            // centerTitle: true,
            // leading: Builder(
            //   builder: (context) => IconButton(
            //     icon: SvgPicture.asset("assets/svg/icons/menu_upbar.svg"),
            //     onPressed: () {
            //       Scaffold.of(context).openEndDrawer();
            //     },
            //   ),
            // ),
          ),
        ),
      ),
      // endDrawer: const DrawerWidget(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      AssetImage('assets/images/user_page_profile.jpg'),
                ),
                const SizedBox(width: 20),
                Text(
                  userController.username.value,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    spreadRadius: 0.5,
                    blurRadius: 5,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/user_detection_icon.gif',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            '감지된 건 ',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '${logController.detectionCount}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                    child: VerticalDivider(
                      width: 0.5,
                      thickness: 1,
                      color: Color.fromARGB(255, 223, 223, 223),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/user_camera_icon.gif',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            '카메라 개수', // 카메라 개수 표시
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${cameraProvider.rtspUrls.length}', // 카메라 개수 표시
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                    child: VerticalDivider(
                      width: 0.5,
                      thickness: 1,
                      color: Color.fromARGB(255, 223, 223, 223),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/user_clip_icon.gif',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            '클립 개수 ',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const Text(
                            '0',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            thickness: 1,
            color: Color.fromARGB(255, 218, 214, 214),
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                ListTile(
                  leading: Image.asset('assets/images/setting_icon.gif',
                      width: 30, height: 30),
                  title: const Text('설정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Image.asset('assets/images/notice_icon.gif',
                      width: 30, height: 30),
                  title: const Text('공지사항'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
