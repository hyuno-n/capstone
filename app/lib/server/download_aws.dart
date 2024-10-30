import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAWS {
  static Future<void> downloadVideo(String url, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';

      final dio = Dio();
      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }
}
