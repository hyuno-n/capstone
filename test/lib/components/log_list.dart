import 'package:flutter/material.dart';

class LogList extends StatelessWidget {
  final List<Map<String, String>> logs;

  LogList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return ListTile(
          title: Text('Action: ${log['action_name']}'),
          subtitle: Text(
              'Time: ${log['timestamp']} | Camera: ${log['camera_number']}'),
        );
      },
    );
  }
}
