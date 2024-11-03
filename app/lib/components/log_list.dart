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

    return SingleChildScrollView(
      child: Column(
        children: sortedDates.map((dateKey) {
          List<Map<String, String>> dateLogs = groupedLogs[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 헤더 표시
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                color: Colors.white,
                child: Text(
                  dateKey,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // 해당 날짜의 로그 리스트 표시
              ...dateLogs.map((log) {
                DateTime dateTime = DateTime.parse(log['timestamp']!);
                String formattedTimestamp =
                    DateFormat('yy.MM.dd HH:mm:ss').format(dateTime);
                String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

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
                    eventIcon = '';
                }

                return Dismissible(
                  key: UniqueKey(), // 항상 고유한 키 사용
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // 로그 항목을 삭제하고 logs 리스트에서도 해당 항목 제거
                    logController.deleteLog(log['user_id']!, log['timestamp']!);
                    logs.removeWhere(
                        (item) => item['timestamp'] == log['timestamp']);

                    // 상태 업데이트
                    logController.update();
                  },
                  child: ListTile(
                    leading: eventIcon.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 13.0, right: 13.0), // 오른쪽 여백 추가
                            child: Image.asset(
                              eventIcon,
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                            ),
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
                          'Camera ${log['camera_number']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          iconSize: 23,
                          onPressed: () {
                            DownloadAWS.downloadVideo(
                                log['event_url']!, context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 28,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    VlcPlayerScreen(url: log['event_url']!),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    //onTap: () {
                    //  showDialog(
                    //    context: context,
                    //    builder: (BuildContext context) {
                    //      return AlertDialog(
                    //        backgroundColor: Colors.white,
                    //        title: const Text('Log Details'),
                    //        content: Column(
                    //          mainAxisSize: MainAxisSize.min,
                    //          crossAxisAlignment: CrossAxisAlignment.start,
                    //          children: [
                    //            Text('Event: ${log['eventname']}'),
                    //            Text('User ID: ${log['user_id']}'),
                    //            Text('Time: $formattedTimestamp'),
                    //            Text('Camera: ${log['camera_number']}'),
                    //            const SizedBox(height: 8),
                    //            const Text('URL:'),
                    //            SelectableText(
                    //              log['event_url'] ?? 'No URL available',
                    //              style: const TextStyle(color: Colors.blue),
                    //              textAlign: TextAlign.left,
                    //              maxLines: null,
                    //            ),
                    //          ],
                    //        ),
                    //        actions: [
                    //          TextButton(
                    //            onPressed: () {
                    //              DownloadAWS.downloadVideo(
                    //                  log['event_url']!, context);
                    //            },
                    //            child: const Text('Download'),
                    //          ),
                    //          TextButton(
                    //            onPressed: () {
                    //              Navigator.of(context).push(
                    //                MaterialPageRoute(
                    //                  builder: (context) => VlcPlayerScreen(
                    //                      url: log['event_url']!),
                    //                ),
                    //              );
                    //            },
                    //            child: const Text('Play'),
                    //          ),
                    //          TextButton(
                    //            onPressed: () {
                    //              Navigator.of(context).pop();
                    //            },
                    //            child: const Text('Close'),
                    //          ),
                    //        ],
                    //      );
                    //    },
                    //  );
                    //},
                  ),
                );
              }).toList(),
              // 각 날짜별 로그 그룹 사이에 경계선 추가
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Color.fromARGB(255, 228, 228, 228),
                  thickness: 1,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
