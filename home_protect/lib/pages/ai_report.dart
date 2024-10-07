import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_protect/components/ai_report_widget.dart';

// ignore: camel_case_types
class AI_report extends StatelessWidget {
  const AI_report({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.2,
        title: const Text(
          "AI report",
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: SvgPicture.asset("assets/svg/icons/menu_upbar.svg"),
            onPressed: () {}),
        actions: [
          IconButton(
            icon: SvgPicture.asset("assets/svg/icons/alarm_upbar.svg"),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: AiWidget(),
      ),
    );
  }
}
