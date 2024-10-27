import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controller/log_controller.dart';
import 'package:app/components/log_list.dart';
import 'package:app/components/drawer_widget.dart';
import 'package:app/components/enddrawer_widget.dart';
import 'package:app/controller/user_controller.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final LogController _logController = Get.put(LogController());
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _logController.initializeNotifications();
    _logController.connectToSocket(updateLogs);
    _logController.fetchLogs(_userController.username.value);
  }

  void updateLogs() {
    setState(() {});
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), // AppBar 기본 높이
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar 배경을 흰색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 그림자 색상
                spreadRadius: 1, // 그림자의 퍼짐 정도
                blurRadius: 5, // 그림자 흐림 정도
                offset: const Offset(0, 2), // 그림자 위치 (아래쪽으로 약간)
              ),
            ],
          ),
          child: AppBar(
            elevation: 0, // 기본 elevation 제거
            backgroundColor: Colors.transparent, // 투명 배경 설정
            title: const Text(
              'Log check',
              style: TextStyle(fontSize: 15),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _logController.clearLogs();
                  updateLogs();
                },
              ),
            ],
          ),
        ),
      ),
      drawer: const DrawerWidget(),
      endDrawer: const EndDrawerWidget(),
      body: Obx(() {
        if (_logController.logs.isEmpty) {
          return const Center(child: Text('No logs available'));
        } else {
          return Column(
            children: [
              Expanded(
                child: LogList(logs: _logController.logs),
              ),
            ],
          );
        }
      }),
    );
  }
}
