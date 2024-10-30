import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoController {
  Future<String> fetchVideoUrl() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:5000/get_video_url'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['url'];
    } else {
      throw Exception('Failed to load video URL');
    }
  }
}
