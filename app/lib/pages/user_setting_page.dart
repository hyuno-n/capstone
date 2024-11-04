// import 'package:app/controller/user_controller.dart';
import 'package:app/pages/account_leave_page.dart';
import 'package:app/pages/how_to_use_app_page.dart';
import 'package:app/pages/user_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final UserController userController = Get.find<UserController>();

    // 예시로 로그인 시 사용자 정보를 설정
    //userController.setUsername('홍길동');
    //userController.setEmail('example@example.com');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            SizedBox(
              width: 100,
            ),
            Text(
              '설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(
            height: 20,
          ),
          // 계정 카테고리
          Text(
            '계정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            //leading: const Icon(Icons.person),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '내 정보',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey[500],
            ),
            onTap: () {
              // UserDetailPage로 이동
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const UserDetailPage(),
              ));
            },
          ),
          ListTile(
            //leading: const Icon(Icons.logout),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '탈퇴하기',
              style: TextStyle(fontSize: 18),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey[500],
            ),
            onTap: () {
              // 여기에 탈퇴하기로 이동하는 코드 추가
              // AccountLeavePage로 이동
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const AccountLeavePage(),
              ));
            },
          ),
          const SizedBox(height: 50),

          // 정보 카테고리
          Text(
            '정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            //leading: const Icon(Icons.info),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '앱 버전',
              style: TextStyle(fontSize: 18),
            ),
            trailing: Text(
              "Beta Test",
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ),
          ListTile(
            //leading: const Icon(Icons.policy),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '도움말',
              style: TextStyle(fontSize: 18),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey[500],
            ),
            onTap: () {
              // 여기에 약관 및 정책으로 이동하는 코드 추가
              // 약관 및 정책 페이지로 이동
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const HowToUseAppPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
