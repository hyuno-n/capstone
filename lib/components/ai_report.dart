import 'package:flutter/material.dart';
import 'package:home_protect/components/ai_widget.dart';
import 'package:home_protect/controller/aws_video.dart'; // Import the VideoController

class AiReport extends StatefulWidget {
  const AiReport({super.key});

  @override
  _AiReportState createState() => _AiReportState();
}

class _AiReportState extends State<AiReport> {
  final List<Map<String, String>> alarms = [];
  final VideoController videoController = VideoController();

  void _addAlarm() async {
    try {
      final videoUrl = await videoController.fetchVideoUrl();
      setState(() {
        alarms.add({
          'date': DateTime.now().toString().substring(0, 19), // 날짜와 시간 포함
          'description': '새로운 이상행동 감지',
          'url': videoUrl,
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching video URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Report'),
      ),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
