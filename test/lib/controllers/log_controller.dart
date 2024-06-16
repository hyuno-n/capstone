import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogController {
  late IO.Socket socket;
  late FlutterLocalNotificationsPlugin localNotifications;
  List<Map<String, String>> logs = [];

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
      String? id = data['id'].toString();
      String? timestamp = data['timestamp'];
      String? eventname = data['eventname'];
      String? cameraNumber = data['camera_number'].toString();

      _showPushMessage(eventname);

      logs.add({
        'id': id ?? 'No id',
        'timestamp': _formatTimestamp(timestamp),
        'eventname': eventname ?? 'No event name',
        'camera_number': cameraNumber ?? 'No camera number',
      });

      updateLogs();
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

  void clearLogs() {
    logs.clear();
  }

  void dispose() {
    socket.dispose();
  }
}
