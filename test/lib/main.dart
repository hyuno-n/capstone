import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io'; // 추가된 부분
import 'package:path/path.dart' as path;
import 'my_home_page.dart'; // 유지하는 부분

Future<void> main() async {
  // 실행 디렉토리의 절대 경로를 설정

  await dotenv.load(fileName: ".env");
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
