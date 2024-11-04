import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      curve:
          const Interval(0.4, 1.0, curve: Curves.easeIn), // 0.9초에 시작해 1.5초에 끝남
    ));

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve:
          const Interval(1.0, 1.0, curve: Curves.easeIn), // 1.5초에 시작해 2.0초에 끝남
    ));

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

  void _confirm() {
    // 확인 버튼 클릭 시 동작
    print("확인 버튼이 클릭되었습니다.");
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
              child: const Text(
                '이제 못보게되는건가요?',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 150), // 간격 추가
            FadeTransition(
              opacity: _buttonAnimation,
              child: ElevatedButton(
                onPressed: _confirm, // 확인 버튼 클릭 시 호출
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
