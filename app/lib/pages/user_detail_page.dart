import 'package:app/controller/user_controller.dart';
import 'package:app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Cupertino 추가
import 'package:get/get.dart'; // UserController 파일 경로에 맞게 수정

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({super.key});

  void _logout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("로그아웃"),
          content: const Text("로그아웃하시겠습니까?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                // 로그아웃 후 LoginPage로 이동
                Get.offAll(() => const Login_Page()); // LoginPage로 이동
              },
              child: const Text("로그아웃"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController =
        Get.find<UserController>(); // UserController 인스턴스 가져오기

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            SizedBox(width: 100),
            Text(
              '내 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 사용자 프로필
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
            const SizedBox(height: 18),

            // 사용자 이름
            Text(
              userController.getUserId, // 사용자 이름 가져오기
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // 사용자 이메일
            Text(
              userController.getEmail, // 이메일 가져오기
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20), // 간격 추가

            // 추가된 텍스트
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이름', // 이름
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4), // 간격 추가
                      Text(
                        userController.getUserId, // user 이름
                        style: TextStyle(fontSize: 20, color: Colors.grey[900]),
                      ),
                      const SizedBox(height: 30), // 간격 추가
                      Text(
                        '이메일', // 이메일
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4), // 간격 추가
                      Text(
                        userController.getEmail, // user 이메일
                        style: TextStyle(fontSize: 20, color: Colors.grey[900]),
                      ),
                      const SizedBox(height: 30), // 간격 추가
                      Text(
                        '전화번호', // 전화번호
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4), // 간격 추가
                      Text(
                        userController.getPhone, // 전화번호
                        style: TextStyle(fontSize: 20, color: Colors.grey[900]),
                      ),
                      const SizedBox(height: 30), // 간격 추가
                    ],
                  ),
                ),
              ],
            ),
            // 경계선 추가
            Divider(
              color: Colors.grey[400],
              thickness: 0.5,
              indent: 35,
              endIndent: 35,
            ),
            // 로그아웃 리스트 타일
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "로그아웃을 하시겠어요?",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                onTap: () => _logout(context), // 로그아웃 함수 호출
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트가 함께 배치되도록 설정
                  children: [
                    Text(
                      "로그아웃",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8), // 아이콘과 텍스트 간의 간격 추가
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 17,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
