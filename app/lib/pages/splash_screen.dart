import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool selected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    // _navigateToHome(); // 주석 처리된 코드
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        selected = !selected;
      });
    });

    // 5초 후에 애니메이션 종료 및 페이지 이동
    Future.delayed(const Duration(seconds: 5), () {
      _timer?.cancel(); // 타이머 정지
      Get.offNamed("/"); // 스플래시 스크린 후 메인 페이지로 이동
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // GIF 이미지 추가
            Image.asset(
              'assets/images/MVCCTV_Splash_logo.gif',
              height: 500, // 이미지 높이 조정 (필요에 따라 조정)
            ),
          ],
        ),
      ),
    );
  }
}
