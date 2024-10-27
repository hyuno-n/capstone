import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendEventToFlask(bool fall_detection_on, bool fire_detection_on,
    bool movement_detection_on, String userId) async {
  final String? flaskAppIp = dotenv.env['FLASK_IP'];
  final String? flaskAppPort = dotenv.env['FLASK_PORT'];
  final String flaskUrl = 'http://$flaskAppIp:$flaskAppPort/receive_event';

  try {
    final response = await http.post(
      Uri.parse(flaskUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'fall_detection': fall_detection_on,
        'fire_detection': fire_detection_on,
        'movement_detection': movement_detection_on,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      print('Event sent to Flask successfully');
    } else {
      print('Failed to send event to Flask: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending event to Flask: $e');
  }
}
