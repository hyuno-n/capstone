import 'package:flutter/material.dart';
import 'package:app/components/ai_report.dart';

// Ai report 페이지 App에서 -> 이 페이지로 넘겨옴 <Ai report main page>

class AiReportPage extends StatelessWidget {
  const AiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정

      // endDrawer: const DrawerWidget(),
      body: Center(
        child: AiReport(),
      ),
    );
  }
}
