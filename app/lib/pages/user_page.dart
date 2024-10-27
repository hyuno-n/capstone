import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app/components/drawer_widget.dart';
import 'package:app/components/enddrawer_widget.dart';
import 'package:app/controller/user_controller.dart';
import 'package:get/get.dart';

class User_page extends StatelessWidget {
  const User_page({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), // AppBar 기본 높이
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar 배경을 흰색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 그림자 색상
                spreadRadius: 0.8, // 그림자의 퍼짐 정도
                blurRadius: 5, // 그림자 흐림 정도
                offset: const Offset(0, 2), // 그림자 위치 (아래쪽으로 약간)
              ),
            ],
          ),
          child: AppBar(
            elevation: 0, // 기본 elevation 제거
            backgroundColor: Colors.transparent, // 투명 배경 설정
            title: const Text(
              "User page",
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
                borderRadius:
                    const BorderRadius.all(Radius.circular(5)), // 모든 모서리를 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13), // 그림자 색상 및 투명도
                    spreadRadius: 0.5, // 그림자의 퍼짐 정도
                    blurRadius: 5, // 그림자의 흐림 정도
                    offset: const Offset(1, 1), // 그림자의 위치 (세로로 3px 아래로 이동)
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
                            'assets/images/user_detection_icon.gif', // GIF 아이콘 경로
                            width: 40, // 아이콘의 너비
                            height: 40, // 아이콘의 높이
                          ),
                          const SizedBox(height: 1), // 아이콘과 텍스트 간격
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '감지된 건 ', // 개행 없이 수평 배치
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '0', // 수평으로 나열
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 50, // 원하는 높이로 설정
                    child: VerticalDivider(
                      width: 0.5, thickness: 1, // 구분선의 두께
                      color: Color.fromARGB(255, 223, 223, 223),
                    ),
                  ), // 구분선 추가
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/user_camera_icon.gif', // GIF 아이콘 경로
                            width: 40, // 아이콘의 너비
                            height: 40, // 아이콘의 높이
                          ),
                          const SizedBox(height: 1), // 아이콘과 텍스트 간격
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '카매라 개수 ', // 개행 없이 수평 배치
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '2', // 수평으로 나열
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 50, // 원하는 높이로 설정
                    child: VerticalDivider(
                      width: 0.5, thickness: 1, // 구분선의 두께
                      color: Color.fromARGB(255, 223, 223, 223),
                    ),
                  ), // 구분선 추가
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/user_clip_icon.gif', // GIF 아이콘 경로
                            width: 40, // 아이콘의 너비
                            height: 40, // 아이콘의 높이
                          ),
                          const SizedBox(height: 1), // 아이콘과 텍스트 간격
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '클립 개수 ', // 개행 없이 수평 배치
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '0', // 수평으로 나열
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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
            indent: 20, // 왼쪽 여백
            endIndent: 20, // 오른쪽 여백
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                ListTile(
                  leading: Image.asset('assets/images/setting_icon.gif',
                      width: 30, height: 30), // GIF 아이콘 추가
                  title: const Text('설정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 설정 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  leading: Image.asset('assets/images/notice_icon.gif',
                      width: 30, height: 30), // GIF 아이콘 추가
                  title: const Text('공지사항'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 공지사항 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
              ],
            ),
          ),
        ],
      ),
    );
  }
}
