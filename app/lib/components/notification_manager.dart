import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  // FlutterLocalNotificationsPlugin의 인스턴스를 생성합니다.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 생성자에서 초기화 메서드를 호출합니다.
  NotificationManager() {
    initializeNotifications();
  }

  // 알림 초기화 메서드
  void initializeNotifications() {
    // 안드로이드 초기화 설정, 앱 아이콘을 지정합니다.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 전체 초기화 설정을 생성합니다.
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 초기화 설정을 사용하여 알림 플러그인을 초기화합니다.
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림을 표시하는 메서드
  Future<void> showNotification(String title, String message) async {
    // 안드로이드 플랫폼 전용 알림 세부 설정을 정의합니다.
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // 알림 채널 ID
      'your_channel_name', // 알림 채널 이름
      channelDescription: 'Your channel description', // 채널 설명
      importance: Importance.max, // 중요도 설정
      priority: Priority.high, // 우선 순위 설정
      ticker: 'ticker', // 티커 텍스트 설정
      playSound: true, // 소리 재생 여부
      styleInformation: DefaultStyleInformation(true, true), // 기본 스타일 정보
      color: Color.fromARGB(255, 0, 123, 255), // 알림 색상 설정
      icon: '@mipmap/ic_launcher', // 알림 아이콘
    );

    // 플랫폼 채널 세부 설정을 생성합니다.
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // 알림을 표시합니다.
    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID (고유 식별자)
      title, // 알림 제목
      message, // 알림 메시지
      platformChannelSpecifics, // 플랫폼 세부 설정
    );
  }
}
