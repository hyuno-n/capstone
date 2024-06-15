import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Push Notification',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IO.Socket _socket;
  late FlutterLocalNotificationsPlugin _localNotifications;
  List<Map<String, String>> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _connectToSocket();
  }

  void _initializeLocalNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _localNotifications.initialize(initializationSettings);
  }

  void _connectToSocket() {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];

    if (flaskIp == null || flaskPort == null) {
      print("FLASK_IP or FLASK_PORT is not set in .env file");
      return;
    }

    _socket = IO.io(
        'http://$flaskIp:$flaskPort',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());

    _socket.connect();

    _socket.on('connect', (_) {
      print('Connected to socket');
    });

    _socket.on('push_message', (data) {
      String? timestamp = data['timestamp'];
      String? actionName = data['action_name'];
      String? cameraNumber = data['camera_number'].toString();

      _showPushMessage(actionName);

      setState(() {
        _logs.add({
          'timestamp': _formatTimestamp(timestamp),
          'action_name': actionName ?? 'No action name',
          'camera_number': cameraNumber ?? 'No camera number',
        });
      });
    });

    _socket.on('disconnect', (_) => print('Disconnected from socket'));
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'No timestamp';
    DateTime parsedTime = DateTime.parse(timestamp);
    String date = DateFormat('yyyy-MM-dd').format(parsedTime);
    String time = DateFormat('HH:mm:ss').format(parsedTime);
    return '$date\n$time';
  }

  Future<void> _showPushMessage(String? actionName) async {
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
    await _localNotifications.show(
      0,
      'Action Detected',
      actionName,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Push Notification'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return ListTile(
                  title: Text('Action: ${log['action_name']}'),
                  subtitle: Text(
                      'Time: ${log['timestamp']} | Camera: ${log['camera_number']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
