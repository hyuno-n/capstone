import 'package:app/controller/log_controller.dart';
import 'package:app/pages/bug_report_page.dart';
import 'package:app/pages/user_setting_page.dart';
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
    final UserController userController = Get.find<UserController>();
    final cameraProvider =
        Provider.of<CameraProvider>(context); // CameraProvider 인스턴스 가져오기
    final logController = Get.find<LogController>();

    return Scaffold(
      backgroundColor: Colors.white,
      // endDrawer: const DrawerWidget(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, // 가로 방향 중앙 정렬
        children: [
          const SizedBox(height: 20), // 위쪽 여백 추가
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color.fromARGB(255, 66, 66, 66),
            ),
            padding: const EdgeInsets.all(18),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 18), // 프로필 사진과 이름 사이의 간격
          Text(
            userController.username.value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4), // 아래쪽 여백 추가
          Text(
            userController.getEmail,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 25), // 아래쪽 여백 추가
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
                          Text(
                            '${logController.videocount}',
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
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    '설정',
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const UserSettingPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(
                    Icons.bug_report,
                  ),
                  title: const Text(
                    '버그 리포트',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const BugReportPage(),
                      ),
                    );
                  },
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
