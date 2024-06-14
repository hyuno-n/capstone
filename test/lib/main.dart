import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'my_home_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  print('FLASK_APP_IP: ${dotenv.env['FLASK_APP_IP']}');
  print('FLASK_APP_PORT: ${dotenv.env['FLASK_APP_PORT']}');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Passing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
