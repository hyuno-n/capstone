import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/server/play_aws.dart';
import 'package:app/server/download_aws.dart';
import 'package:app/controller/log_controller.dart';
import 'package:get/get.dart';

class LogList extends StatelessWidget {
  final List<Map<String, String>> logs;
  final LogController logController = Get.find<LogController>();

  LogList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        DateTime dateTime = DateTime.parse(log['timestamp']!);
        String formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

        return Dismissible(
          key: Key(log['timestamp'] ?? DateTime.now().toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            logController.deleteLog(log['user_id']!, log['timestamp']!);
          },
          child: ListTile(
            title: Text('Event: ${log['eventname']}'),
            subtitle: Text(
              'ID: ${log['user_id']} | Time: $formattedTimestamp | Camera: ${log['camera_number']}',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Log Details'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event: ${log['eventname']}'),
                        Text('User ID: ${log['user_id']}'),
                        Text('Time: $formattedTimestamp'),
                        Text('Camera: ${log['camera_number']}'),
                        SizedBox(height: 8),
                        Text('URL:'),
                        SelectableText(
                          log['event_url'] ?? 'No URL available',
                          style: TextStyle(color: Colors.blue),
                          textAlign: TextAlign.left,
                          maxLines: null,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          DownloadAWS.downloadVideo(log['event_url']!, context);
                        },
                        child: Text('Download'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  VlcPlayerScreen(url: log['event_url']!),
                            ),
                          );
                        },
                        child: Text('Play'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
