import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class FullscreenVideoPage extends StatefulWidget {
  final String rtspUrl;

  const FullscreenVideoPage({super.key, required this.rtspUrl});

  @override
  _FullscreenVideoPageState createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  late VlcPlayerController vlcViewController;

  @override
  void initState() {
    super.initState();
    vlcViewController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(3000), // 네트워크 캐싱 시간 조정 (3초)
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
    print('Playing video from URL: ${widget.rtspUrl}');
    vlcViewController.addListener(() {
      final state = vlcViewController.value.playingState;
      print('VLC player state: $state');
    });
  }

  @override
  void dispose() {
    vlcViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: VlcPlayer(
          controller: vlcViewController,
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          placeholder: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
