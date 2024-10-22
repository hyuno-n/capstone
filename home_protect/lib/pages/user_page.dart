import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';
import 'package:home_protect/controller/user_controller.dart';
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
                spreadRadius: 1, // 그림자의 퍼짐 정도
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
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '감지된 건\n',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '0',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 70,
                    color: const Color(0xFFDDDDDD),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '카메라 개수\n',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '2',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '클립 개수\n',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '0',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                ListTile(
                  title: const Text('설정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 설정 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  title: const Text('프로필 변경'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 프로필 변경 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  title: const Text('공지사항'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 공지사항 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  title: const Text('고객센터'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 고객센터 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  title: const Text('1:1 문의 내역'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 1:1 문의 내역 클릭 시 동작
                  },
                ),
                const SizedBox(height: 10), // 버튼 간격 추가
                ListTile(
                  title: const Text('카메라 정보'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 카메라 정보 클릭 시 동작
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
