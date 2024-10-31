import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/server/play_aws.dart';
import 'package:app/server/download_aws.dart';
import 'package:app/controller/log_controller.dart';
import 'package:get/get.dart';

class LogList extends StatelessWidget {
  final List<Map<String, String>> logs;
  final LogController logController = Get.find<LogController>();

  LogList({super.key, required this.logs});

  // 로그 데이터를 날짜별로 그룹화하고 최신순으로 정렬하는 함수
  Map<String, List<Map<String, String>>> _groupLogsByDate() {
    Map<String, List<Map<String, String>>> groupedLogs = {};

    for (var log in logs) {
      DateTime dateTime = DateTime.parse(log['timestamp']!);
      String dateKey =
          DateFormat('yy.MM.dd').format(dateTime); // 날짜 형식을 yy.MM.dd로 설정

      if (groupedLogs[dateKey] == null) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(log);
    }

    // 각 날짜별 로그를 최신순으로 정렬
    groupedLogs.forEach((key, value) {
      value.sort((a, b) => DateTime.parse(b['timestamp']!)
          .compareTo(DateTime.parse(a['timestamp']!)));
    });

    return groupedLogs;
  }

  @override
  Widget build(BuildContext context) {
    final groupedLogs = _groupLogsByDate();
    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 날짜 순으로 정렬 (최신 날짜가 위로)

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        String dateKey = sortedDates[dateIndex];
        List<Map<String, String>> dateLogs = groupedLogs[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더 표시
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              color: Colors.white,
              child: Text(
                dateKey,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 해당 날짜의 로그 리스트 표시
            ...dateLogs.map((log) {
              DateTime dateTime = DateTime.parse(log['timestamp']!);
              String formattedTimestamp =
                  DateFormat('yy.MM.dd HH:mm:ss').format(dateTime);

              String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

              // 이벤트 이름에 따라 다른 아이콘을 사용하도록 설정
              String eventIcon;
              switch (log['eventname']) {
                case 'Movement':
                  eventIcon = 'assets/images/suspect_icon.gif';
                  break;
                case 'Fire':
                  eventIcon = 'assets/images/fire_log_icon.gif';
                  break;
                case 'Fall':
                  eventIcon = 'assets/images/fall_detection_on.gif';
                  break;
                default:
                  eventIcon = ''; // 아이콘이 필요 없을 때 기본값
              }

              return Dismissible(
                key: Key(log['timestamp'] ?? DateTime.now().toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  logController.deleteLog(log['user_id']!, log['timestamp']!);
                },
                child: ListTile(
                  leading: eventIcon.isNotEmpty
                      ? Image.asset(
                          eventIcon,
                          width: 55,
                          height: 55,
                          fit: BoxFit.contain,
                        )
                      : null,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['eventname']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        '${log['user_id']} / Camera ${log['camera_number']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Log Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event: ${log['eventname']}'),
                              Text('User ID: ${log['user_id']}'),
                              Text('Time: $formattedTimestamp'),
                              Text('Camera: ${log['camera_number']}'),
                              const SizedBox(height: 8),
                              const Text('URL:'),
                              SelectableText(
                                log['event_url'] ?? 'No URL available',
                                style: const TextStyle(color: Colors.blue),
                                textAlign: TextAlign.left,
                                maxLines: null,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                DownloadAWS.downloadVideo(
                                    log['event_url']!, context);
                              },
                              child: const Text('Download'),
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
                              child: const Text('Play'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            }),
            // 각 날짜별 로그 그룹 사이에 경계선 추가
            if (dateIndex < sortedDates.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20), // 수평 여백 설정
                child: Divider(
                  color: Color.fromARGB(255, 228, 228, 228),
                  thickness: 1,
                ),
              ),
          ],
        );
      },
    );
  }
}
