import 'dart:math'; // Random 클래스 사용을 위한 임포트
import 'package:app/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/controller/user_controller.dart';
import 'package:get/get.dart';

class AccountLeavePage extends StatefulWidget {
  const AccountLeavePage({super.key});

  @override
  _AccountLeavePageState createState() => _AccountLeavePageState();
}

class _AccountLeavePageState extends State<AccountLeavePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _imageAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;

  final UserController userController = Get.put(UserController());

  // 랜덤 문장 선택을 위한 변수
  final List<String> messages = [
    '이제 못 보게 되는 건가요?',
    '정말로 탈퇴하시는 건가요?',
    '이제 이별인가요? 너무 아쉬워요.',
    '정말로 떠나는 건가요?'
  ];
  late final String selectedMessage;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500), // 전체 애니메이션 시간
      vsync: this,
    );

    _imageAnimation = Tween<Offset>(
      begin: Offset(0, 0.2), // 아래에서 살짝 나타남
      end: Offset.zero, // 최종 위치
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn), // 텍스트 애니메이션
    ));

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(1.0, 1.0, curve: Curves.easeIn), // 버튼 애니메이션
    ));

    // 랜덤으로 문장 선택
    selectedMessage = messages[Random().nextInt(messages.length)];

    // 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 리소스 정리
    super.dispose();
  }

  void _showConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('탈퇴하기'),
        content: const Text('정말로 탈퇴하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () async {
              await userController.deleteAccount();
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Get.offAll(() => const Login_Page());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        iconTheme: const IconThemeData(color: Colors.white), // 아이콘 색상 변경
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 120), // 간격 추가
            SlideTransition(
              position: _imageAnimation,
              child: Image.asset(
                'assets/images/leave_account_page_icon.png',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                selectedMessage, // 선택된 랜덤 문장 표시
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 150), // 간격 추가
            FadeTransition(
              opacity: _buttonAnimation,
              child: ElevatedButton(
                onPressed: _showConfirmationDialog, // 확인 버튼 클릭 시 호출
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 143, 143, 143),
                  backgroundColor:
                      const Color.fromARGB(255, 8, 71, 122), // 버튼 배경 색상
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 9), // 버튼 크기 조절
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // 테두리 radius 조절
                  ),
                ),
                child: const Text(
                  '탈퇴하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ), // 버튼 텍스트
              ),
            ),
          ],
        ),
      ),
    );
  }
}
