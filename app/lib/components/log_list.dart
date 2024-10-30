import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl 패키지 가져오기

class LogList extends StatelessWidget {
  final List<Map<String, String>> logs;

  LogList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        // timestamp 필드를 DateTime으로 변환 후, 원하는 형식으로 변환
        DateTime dateTime = DateTime.parse(log['timestamp']!);
        String formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

        return ListTile(
          title: Text('Event: ${log['eventname']}'),
          subtitle: Text(
              'ID: ${log['user_id']} | Time: $formattedTimestamp | Camera: ${log['camera_number']}'),
        );
      },
    );
  }
}
