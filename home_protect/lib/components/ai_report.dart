import 'package:flutter/material.dart';
import 'package:home_protect/components/ai_widget.dart';
import 'package:home_protect/components/notifications.dart';
import 'package:home_protect/controller/aws_video.dart'; // Import the VideoController

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport> {
  final List<Map<String, String>> alarms = [];
  final VideoController videoController = VideoController();
  final NotificationService notificationService =
      NotificationService(); // NotificationService 인스턴스 생성

  void _addAlarm() async {
    try {
      final videoUrl = await videoController.fetchVideoUrl();
      final currentTime =
          DateTime.now().toString().substring(0, 19); // 현재 날짜와 시간
      setState(() {
        alarms.add({
          'date': currentTime,
          'description': '새로운 이상행동 감지',
          'url': videoUrl,
        });
      });

      // 푸시 알림 표시
      notificationService.showNotification(
        '$currentTime - New Dection',
        '새로운 이상행동이 감지되었습니다.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching video URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: alarms.map((alarm) {
          return AiWidget(
            date: alarm['date']!,
            description: alarm['description']!,
            videoUrl: alarm['url']!,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
