import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 제목 설정
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.chevron_left,
            size: 38,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(
                  "알림",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 알림과 아이콘 사이에 여백 추가
            Row(
              children: [
                SizedBox(width: 30), // 왼쪽 여백
                Icon(
                  Icons.warning, // 경고 아이콘
                  color: Colors.red, // 아이콘 색상
                  size: 20, // 아이콘 크기
                ),
                SizedBox(width: 7), // 아이콘과 텍스트 사이 여백
                Text(
                  "Fall / Camera1", // 아이콘 아래 텍스트
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey, // 텍스트 색상
                  ),
                ),
              ],
            ),
            SizedBox(height: 5), // 아이콘과 설명 텍스트 사이에 여백 추가
            Row(
              children: [
                SizedBox(width: 57), // 왼쪽 여백
                Text(
                  "00일 00시 00분 넘어짐이 감지되었습니다.", // 추가 설명 텍스트
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 30), // 왼쪽 여백
                Icon(
                  Icons.warning, // 경고 아이콘
                  color: Colors.red, // 아이콘 색상
                  size: 20, // 아이콘 크기
                ),
                SizedBox(width: 7), // 아이콘과 텍스트 사이 여백
                Text(
                  "Fall / Camera1", // 아이콘 아래 텍스트
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey, // 텍스트 색상
                  ),
                ),
              ],
            ),
            SizedBox(height: 5), // 아이콘과 설명 텍스트 사이에 여백 추가
            Row(
              children: [
                SizedBox(width: 57), // 왼쪽 여백
                Text(
                  "00일 00시 00분 넘어짐이 감지되었습니다.", // 추가 설명 텍스트
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
