import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class Streaming2 extends StatelessWidget {
  final bool showVolumeSlider;

  const Streaming2({required this.showVolumeSlider, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamingPage2(showVolumeSlider: showVolumeSlider);
  }
}

class StreamingPage2 extends StatefulWidget {
  final bool showVolumeSlider;

  const StreamingPage2({required this.showVolumeSlider, super.key});

  @override
  _StreamingPageState2 createState() => _StreamingPageState2();
}

class _StreamingPageState2 extends State<StreamingPage2> {
  late VlcPlayerController vlcViewController;
  final String rtspUrl = "rtsp://210.99.70.120:1935/live/cctv001.stream";
  double _volume = 100.0;

  @override
  void initState() {
    super.initState();
    vlcViewController = VlcPlayerController.network(
      rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    vlcViewController.dispose();
    super.dispose();
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
    });
    vlcViewController.setVolume(volume.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: VlcPlayer(
            controller: vlcViewController,
            aspectRatio: 16 / 9,
            placeholder: const SizedBox(
              height: 250.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
        if (widget.showVolumeSlider)
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: SizedBox(
              width: 300, // 슬라이더의 가로 길이 조절
              child: Slider(
                value: _volume,
                min: 0,
                max: 100,
                onChanged: _setVolume,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
