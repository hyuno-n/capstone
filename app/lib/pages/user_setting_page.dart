import 'package:flutter/material.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('프로필 설정'),
            onTap: () {
              // 여기에 프로필 설정으로 이동하는 코드 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            onTap: () {
              // 여기에 알림 설정으로 이동하는 코드 추가
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보 설정'),
            onTap: () {
              // 여기에 개인정보 설정으로 이동하는 코드 추가
            },
          ),
          // 필요에 따라 더 많은 ListTile 추가
        ],
      ),
    );
  }
}
