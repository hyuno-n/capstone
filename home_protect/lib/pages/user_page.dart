import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';

class User_page extends StatelessWidget {
  const User_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.2,
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
      drawer: const DrawerWidget(),
      endDrawer: const EndDrawerWidget(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 시작점에서 정렬
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20.0, left: 20.0), // 상단과 좌측 여백 추가
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      AssetImage('assets/images/profile.jpg'), // 프로필 사진 경로
                ),
                SizedBox(width: 20), // 이미지와 텍스트 사이 간격
                Text(
                  "John Doe", // 사용자 이름
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25), // 프로필과 박스 사이에 여백 추가

          // 아래에 3개의 수평으로 나뉜 회색 박스
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80, // 박스의 높이
                    color: Colors.grey[300], // 박스의 배경색
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black), // 기본 텍스트 스타일
                          children: [
                            TextSpan(
                              text: '감지된 건\n',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black, // 텍스트 색상
                              ),
                            ),
                            TextSpan(
                              text: '0', // 숫자 0을 굵게 표시
                              style: TextStyle(
                                fontSize: 30, // 숫자를 더 크게
                                fontWeight: FontWeight.bold, // 굵게
                                color: Colors.black, // 텍스트 색상
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4), // 박스 사이 간격
                Expanded(
                  child: Container(
                    height: 80, // 박스의 높이
                    color: Colors.grey[300], // 박스의 배경색
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
                                fontSize: 30,
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
                const SizedBox(width: 4), // 박스 사이 간격
                Expanded(
                  child: Container(
                    height: 80, // 박스의 높이
                    color: Colors.grey[300], // 박스의 배경색
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
                                fontSize: 30,
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
        ],
      ),
    );
  }
}
