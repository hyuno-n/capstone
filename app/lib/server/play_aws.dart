import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:app/pages/notification_page.dart';

class VlcPlayerScreen extends StatefulWidget {
  final String url;

  VlcPlayerScreen({required this.url});

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
      hwAcc: HwAcc.full, // 하드웨어 가속 옵션
      autoPlay: true, // 자동 재생 설정
    );
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar 배경색을 흰색으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 0.1,
                blurRadius: 5,
                offset: const Offset(0, 2), // 그림자를 아래쪽에 위치
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/MVCCTV_main.png',
                  height: 180, // 이미지 높이 조정
                ),
              ],
            ),
            actions: [
              SizedBox(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      iconSize: 32,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 61, 61),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
      body: Center(
        child: VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _vlcController.value.isPlaying
                ? _vlcController.pause()
                : _vlcController.play();
          });
        },
        child: Icon(
          _vlcController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
