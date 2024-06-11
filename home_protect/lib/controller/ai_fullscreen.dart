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
  bool _isPlaying = true;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    vlcViewController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(4000), // 네트워크 캐싱 시간 조정 (3초)
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(false),
        ]),
      ),
    );
    vlcViewController.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    if (!mounted) return;
    setState(() {
      _sliderValue = vlcViewController.value.position.inSeconds.toDouble();
    });
  }

  @override
  void dispose() {
    vlcViewController.removeListener(_onPlayerStateChanged);
    vlcViewController.dispose();
    super.dispose();
  }

  void _onPlayPauseButtonPressed() {
    setState(() {
      if (_isPlaying) {
        vlcViewController.pause();
      } else {
        vlcViewController.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      vlcViewController.setTime((value * 1000).toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VlcPlayer(
              controller: vlcViewController,
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Slider(
                  value: _sliderValue,
                  min: 0.0,
                  max: (vlcViewController.value.duration.inSeconds).toDouble(),
                  onChanged: _onSliderChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _onPlayPauseButtonPressed,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${_formatDuration(vlcViewController.value.position)} / ${_formatDuration(vlcViewController.value.duration)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
