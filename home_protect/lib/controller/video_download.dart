import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class VideoDownloadController {
  Future<String> downloadVideo(String url, String fileName) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = '${directory.path}/$fileName';
        final response = await http.get(Uri.parse(url));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to get storage directory');
      }
    } else {
      throw Exception('Storage permission denied');
    }
  }
}
