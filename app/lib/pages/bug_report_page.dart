import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  _BugReportPageState createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "어떤 버그가 발생했는지 알려주세요!", "isUser": false},
  ];

  final List<String> _thankYouMessages = [
    "버그 신고를 해주셔서 감사합니다.",
    "서비스 개선을 위해 의견을 주셔서 감사합니다.",
    "적극 검토하여 개선된 서비스를 제공하겠습니다.",
    "좋은 의견 감사합니다.",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // 사용자가 입력한 텍스트를 디버그 콘솔에 출력
      debugPrint('버그 리포트 내용: ${_controller.text}');

      setState(() {
        _messages.add({"text": _controller.text, "isUser": true});
      });

      // 2초 후에 감사 메시지를 추가
      Future.delayed(const Duration(seconds: 2), () {
        final randomIndex = Random().nextInt(_thankYouMessages.length);
        setState(() {
          _messages
              .add({"text": _thankYouMessages[randomIndex], "isUser": false});
        });
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[600],
          ),
        ),
        title: Row(
          children: [
            SizedBox(
              width: 58,
            ),
            Text(
              "Bug Message",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["isUser"] as bool;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color.fromARGB(255, 52, 184, 74)
                          : const Color.fromARGB(255, 182, 182, 182),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message["text"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 49, 49, 49),
                      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // 내부 여백 설정
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                          color: Colors.white), // 텍스트 색상을 흰색으로 설정
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 77, 77, 77),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    color: Color.fromARGB(255, 52, 184, 74),
                  ), // Cupertino 아이콘 설정
                  iconSize: 35,
                  color: Colors.blue,
                  onPressed: _sendMessage,
                ),
                const SizedBox(
                  width: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
