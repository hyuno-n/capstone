import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/controller/log_controller.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final LogController logController = Get.find<LogController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.chevron_left,
            size: 38,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (logController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (logController.hasError.value) {
          return const Center(child: Text('알림을 불러오지 못했습니다.'));
        }
        if (logController.logs.isEmpty) {
          return const Center(child: Text('새로운 알림이 없습니다.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "알림" 제목 표시
              Row(
                children: const [
                  SizedBox(width: 30),
                  Text(
                    "알림",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 로그 알림 리스트 표시
              ...logController.logs.map((log) {
                DateTime timestamp = DateTime.parse(log['timestamp']!);
                String formattedDate =
                    DateFormat('yy.MM.dd HH:mm').format(timestamp);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 30),
                        const Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${log['eventname']} / Camera ${log['camera_number']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 57.0),
                      child: Text(
                        '$formattedDate - ${log['eventname']}이 감지되었습니다.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }
}
