import 'package:app/components/video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/controller/log_controller.dart';
import 'package:get/get.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  _MonitoringState createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  final LogController logController =
      Get.find<LogController>(); // LogController 인스턴스

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: VideoWidget(),
      ),
    );
  }
}
