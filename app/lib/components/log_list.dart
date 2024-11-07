import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/server/download_aws.dart';
import 'package:app/controller/log_controller.dart';
import 'package:get/get.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:app/components/loading_indicator.dart'; // LoadingIndicator import
import 'dart:ui';
import 'package:flutter/services.dart';

class LogList extends StatelessWidget {
  final List<Map<String, String>> videoclips;
  final LogController logController = Get.find<LogController>();

  LogList({super.key, required this.videoclips});

  Map<String, List<Map<String, String>>> _groupLogsByDate() {
    Map<String, List<Map<String, String>>> groupedLogs = {};

    for (var videoclip in videoclips) {
      DateTime dateTime = DateTime.parse(videoclip['timestamp']!);
      String dateKey = DateFormat('yy.MM.dd').format(dateTime);

      if (groupedLogs[dateKey] == null) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(videoclip);
    }

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
      ..sort((a, b) => b.compareTo(a));
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Column(
        children: sortedDates.map((dateKey) {
          List<Map<String, String>> dateLogs = groupedLogs[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ...dateLogs.map((videoclips) {
                DateTime dateTime = DateTime.parse(videoclips['timestamp']!);
                String formattedTime =
                    DateFormat('HH시 mm분 ss초').format(dateTime);

                String eventIcon;
                switch (videoclips['eventname']) {
                  case 'Movement':
                    eventIcon = 'assets/images/suspect_icon.gif';
                    break;
                  case 'Fire':
                    eventIcon = 'assets/images/fire_log_icon.gif';
                    break;
                  case 'Fall':
                    eventIcon = 'assets/images/fall_detection_on.gif';
                    break;
                  case 'Smoke':
                    eventIcon = 'assets/images/smoke_log_icon.gif';
                    break;
                  default:
                    eventIcon = '';
                }

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    logController.deleteLog(
                        videoclips['user_id']!, videoclips['timestamp']!);
                    dateLogs.removeWhere(
                        (item) => item['timestamp'] == videoclips['timestamp']);
                    logController.update();
                  },
                  child: ListTile(
                    leading: eventIcon.isNotEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 13.0, right: 13.0),
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
                          videoclips['eventname']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          'Camera ${cameraProvider.getCameraIndex(int.parse(videoclips['camera_number']!))}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showFullScreenVideo(context, videoclips['event_url']!);
                    },
                  ),
                );
              }),
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

  void _showFullScreenVideo(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.download, color: Colors.blue),
                            onPressed: () {
                              DownloadAWS.downloadVideo(url, context);
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: VlcPlayerScreen(url: url),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '닫기',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenVideoPlayer(url: url),
                                ),
                              );
                            },
                            child: const Text(
                              '전체 화면',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class VlcPlayerScreen extends StatefulWidget {
  final String url;
  final bool fullScreen;

  const VlcPlayerScreen({required this.url, this.fullScreen = false});

  @override
  _VlcPlayerScreenState createState() => _VlcPlayerScreenState();
}

class _VlcPlayerScreenState extends State<VlcPlayerScreen> {
  late VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );

    if (widget.fullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VlcPlayer(
        controller: _vlcController,
        aspectRatio: 16 / 9,
        placeholder: LoadingIndicator(), // LoadingIndicator 적용
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final String url;

  const FullScreenVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VlcPlayerScreen(url: url, fullScreen: true),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () async {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
