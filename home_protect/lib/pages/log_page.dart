import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_protect/controller/log_controller.dart';
import 'package:home_protect/components/log_list.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';
import 'package:home_protect/controller/user_controller.dart';

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
      appBar: AppBar(
        elevation: 1.2,
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
