import 'package:flutter/material.dart';
import '../components/log_list.dart';
import '../controllers/log_controller.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LogController _logController = LogController();

  @override
  void initState() {
    super.initState();
    _logController.initializeNotifications();
    _logController.connectToSocket(updateLogs);
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
        title: Text('Flutter Push Notification'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _logController.clearLogs();
              updateLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LogList(logs: _logController.logs),
          ),
        ],
      ),
    );
  }
}
