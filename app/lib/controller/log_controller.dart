import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogController extends GetxController {
  late IO.Socket socket;
  late FlutterLocalNotificationsPlugin localNotifications;
  var logs = <Map<String, String>>[].obs;
  String currentUserId = '';

  void initializeNotifications() {
    localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    localNotifications.initialize(initializationSettings);
  }

  void connectToSocket(Function updateLogs) {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];

    if (flaskIp == null || flaskPort == null) {
      print("FLASK_IP or FLASK_PORT is not set in .env file");
      return;
    }

    socket = IO.io(
        'http://$flaskIp:$flaskPort',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to socket');
    });

    socket.on('push_message', (data) {
      print('Received push_message event: $data'); // Debugging log

      String? userId = data['user_id']?.toString();
      String? timestamp = data['timestamp'];
      String? eventname = data['eventname'];
      String? cameraNumber = data['camera_number']?.toString();

      print('Parsed user_id: $userId'); // Debugging log

      if (userId == currentUserId) {
        _showPushMessage(eventname);

        logs.add({
          'user_id': userId ?? 'No user id',
          'timestamp': _formatTimestamp(timestamp),
          'eventname': eventname ?? 'No event name',
          'camera_number': cameraNumber ?? 'No camera number',
        });

        updateLogs();
      } else {
        print('Event not for current user: $userId');
      }
    });

    socket.on('disconnect', (_) => print('Disconnected from socket'));
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'No timestamp';
    DateTime parsedTime = DateTime.parse(timestamp);
    String date = DateFormat('yyyy-MM-dd').format(parsedTime);
    String time = DateFormat('HH:mm:ss').format(parsedTime);
    return '$date\n$time';
  }

  Future<void> _showPushMessage(String? eventname) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await localNotifications.show(
      0,
      'Event Detected',
      eventname,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void clearLogs() async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/delete_user_events';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'user_id': currentUserId}),
      );
      if (response.statusCode == 200) {
        logs.clear();
        print('Logs cleared successfully');
      } else {
        print('Failed to clear logs: ${response.body}');
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }

  Future<void> fetchLogs(String userId) async {
    currentUserId = userId; // 로그인된 사용자 ID 설정
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/get_user_events/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedLogs = jsonDecode(response.body);
        List<Map<String, String>> parsedLogs = fetchedLogs.map((dynamic log) {
          return {
            'timestamp': log['timestamp'].toString(),
            'eventname': log['eventname'].toString(),
          };
        }).toList();
        logs.value = parsedLogs;
      } else {
        print('Failed to fetch logs: ${response.body}');
      }
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  void setCurrentUserId(String userId) {
    currentUserId = userId;
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
