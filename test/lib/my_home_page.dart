import 'dart:async';
import 'package:flutter/material.dart';
import 'message_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String message;
  late Timer timer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    message = 'Waiting for message...';
    getMessage(); // 초기에 한 번 호출
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getMessage());
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> getMessage() async {
    try {
      final response = await MessageService.getMessage();

      setState(() {
        if (response.statusCode == 200) {
          message = response.body;
        } else {
          message = 'Failed to fetch message';
        }
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  Future<void> sendMessage(String newMessage) async {
    try {
      final response = await MessageService.setMessage(newMessage);

      setState(() {
        if (response.statusCode == 200) {
          message = newMessage;
        } else {
          message = 'Failed to send message';
        }
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Passing Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Message from Flask:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter new message',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sendMessage(_controller.text);
                _controller.clear();
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
