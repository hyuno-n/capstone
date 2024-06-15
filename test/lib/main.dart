import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  @override
  void initState() {
    super.initState();
    _connectToSocket();
  }

  void _connectToSocket() {
    _socket = IO.io(
        'http://${dotenv.env['FLASK_IP']}:${dotenv.env['FLASK_PORT']}',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        });

    _socket.connect();

    _socket.on('connect', (_) {
      print('Connected to socket');
    });

    _socket.on('push_message', (data) {
      _showPushMessage(data['message']);
    });

    _socket.on('disconnect', (_) => print('Disconnected from socket'));
  }

  void _showPushMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Push Notification'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
      ),
      body: Center(
        child: Text('Waiting for message...'),
      ),
    );
  }
}
