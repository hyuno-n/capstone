import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:app/controller/log_controller.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/camera_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  final LogController logController = Get.find<LogController>();
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700), // 애니메이션 시간 설정
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset(0, 0.2), // 아래에서 살짝 나타남
      end: Offset.zero, // 최종 위치
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // 자연스러운 커브
    ));

    // 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
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
          return Center(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                    ),
                    SlideTransition(
                      position: _animation,
                      child: Image.asset(
                        'assets/images/no_alram_icon.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ), // 이미지와 텍스트 간격
                    const Text(
                      '알림이 없습니다',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    DateFormat('MM월 dd일 HH시').format(timestamp);
                int cameraIndex = cameraProvider
                    .getCameraIndex(int.parse(log['camera_number']!));
                // 이벤트 이름에 따른 메시지, 아이콘 및 색상 결정
                String alertMessage;
                IconData iconData;
                Color? iconColor;

                switch (log['eventname']) {
                  case 'Movement':
                    alertMessage = '움직임이 감지되었습니다.';
                    iconData = Icons.directions_walk;
                    iconColor = Colors.blue;
                    break;
                  case 'Fall':
                    alertMessage = '넘어짐이 감지되었습니다.';
                    iconData = Icons.report;
                    iconColor = Colors.orange;
                    break;
                  case 'Fire':
                    alertMessage = '화재가 감지되었습니다.';
                    iconData = Icons.whatshot;
                    iconColor = Colors.red;
                    break;
                  case 'Smoke':
                    alertMessage = '연기가 감지되었습니다.';
                    iconData = Icons.cloud;
                    iconColor = Colors.grey[700];
                    break;
                  default:
                    alertMessage = '알 수 없는 이벤트입니다.';
                    iconData = Icons.error; // 기본 아이콘
                    iconColor = Colors.grey; // 기본 색상
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 30),
                        Icon(
                          iconData,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${log['eventname']} / Camera $cameraIndex',
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
                        '$formattedDate - $alertMessage',
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
