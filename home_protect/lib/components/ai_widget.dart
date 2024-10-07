import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_protect/controller/ai_fullscreen.dart';
import 'package:home_protect/controller/video_download.dart';

class AiWidget extends StatelessWidget {
  final String date;
  final String description;
  final String videoUrl;

  const AiWidget({
    super.key,
    required this.date,
    required this.description,
    required this.videoUrl,
  });

  Future<void> _playVideo(BuildContext context) async {
    try {
      print('fetched video URL: $videoUrl');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullscreenVideoPage(rtspUrl: videoUrl),
        ),
      );
    } catch (e) {
      print('Error fetching video URL: $e');
    }
  }

  Future<void> _downloadVideo(BuildContext context, String url) async {
    final downloadController = VideoDownloadController();
    try {
      final filePath =
          await downloadController.downloadVideo(url, 'downloaded_video.mp4');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video downloaded to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading video: $e')),
      );
    }
  }

  Widget _reportAlarm(String date, String description, BuildContext context) {
    final datePart = date.substring(0, 10);
    final timePart = date.substring(11, 19);

    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '$datePart\n'),
                  TextSpan(text: timePart),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(description),
          ),
          IconButton(
            icon: SvgPicture.asset("assets/svg/icons/play_button.svg"),
            onPressed: () => _playVideo(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await _downloadVideo(context, videoUrl);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _reportAlarm(date, description, context);
  }
}
