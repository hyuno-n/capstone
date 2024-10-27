import 'package:flutter/material.dart';

class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 80.0, // 원하는 높이로 설정
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Align(
              alignment: Alignment(0.0, 0.3),
              child: Text(
                'History report',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
