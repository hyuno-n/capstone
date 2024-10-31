import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/notification_manager.dart';
import '../server/socket_manager.dart';

// LogController 클래스는 사용자의 로그 기록과 알림을 관리하며, 서버와의 소켓 통신을 처리하는 GetX 컨트롤러입니다.
class LogController extends GetxController {
  late NotificationManager
      notificationManager; // 알림을 관리하는 NotificationManager 인스턴스
  late SocketManager socketManager; // 소켓 연결을 관리하는 SocketManager 인스턴스
  var logs = <Map<String, String>>[].obs; // 관찰 가능한 형식으로 저장된 로그 리스트
  int detectionCount = 0; // 총 감지된 이벤트 수
  String currentUserId = ''; // 현재 사용자의 ID

  // 컨트롤러 초기화 메소드로서 알림 관리자 초기화
  @override
  void onInit() {
    super.onInit();
    notificationManager = NotificationManager(); // NotificationManager 인스턴스 생성
  }

  // 소켓 연결을 초기화하고 현재 사용자 ID를 기반으로 연결하는 메소드
  void connectSocket() {
    socketManager = SocketManager(
        notificationManager, this); // 알림 관리자와 현재 컨트롤러 인스턴스로 SocketManager 초기화
    socketManager.connectToSocket(currentUserId); // 소켓에 연결하고 현재 사용자 ID 전달
  }

  // 서버로부터 수신된 메시지를 처리하는 메소드
  void handleIncomingMessage(Map<String, dynamic> data) {
    detectionCount++; // 새로운 이벤트 수신 시 감지 횟수 증가
    String userId = data['user_id'] ??
        "Unknown User"; // 수신된 데이터에서 사용자 ID 가져오기 (없을 경우 "Unknown User" 사용)
    String timestamp = data['timestamp'] ??
        DateTime.now().toIso8601String(); // 타임스탬프 (없을 경우 현재 시간 사용)
    String eventname =
        data['eventname'] ?? "New Event"; // 이벤트 이름 (없을 경우 "New Event" 사용)
    String cameraNumber =
        data['camera_number']?.toString() ?? "N/A"; // 카메라 번호 (없을 경우 "N/A" 사용)
    String eventUrl = data['event_url'] ?? ''; // 이벤트 관련 URL (없을 경우 빈 문자열 사용)

    // 로그 리스트에 새로운 이벤트 추가
    logs.add({
      'user_id': userId,
      'timestamp': timestamp,
      'eventname': eventname,
      'camera_number': cameraNumber,
      'event_url': eventUrl,
    });
  }

  // 서버로부터 로그 데이터를 가져오는 메소드
  Future<void> fetchLogs(String userId) async {
    currentUserId = userId; // 현재 사용자 ID 설정
    final String? flaskIp = dotenv.env['FLASK_IP']; // 환경 변수에서 Flask 서버 IP 가져오기
    final String? flaskPort =
        dotenv.env['FLASK_PORT']; // 환경 변수에서 Flask 서버 포트 가져오기
    final String url =
        'http://$flaskIp:$flaskPort/get_user_events/$userId'; // 로그 가져올 URL 조합

    try {
      final response = await http.get(Uri.parse(url)); // HTTP GET 요청 보내기
      if (response.statusCode == 200) {
        // 응답이 성공적일 경우
        List<dynamic> fetchedLogs = jsonDecode(response.body); // JSON 형태로 파싱
        logs.value = fetchedLogs.map((dynamic log) {
          return {
            'user_id': log['user_id']?.toString() ?? '',
            'timestamp': log['timestamp']?.toString() ?? '',
            'eventname': log['eventname']?.toString() ?? '',
            'camera_number': log['camera_number']?.toString() ?? '',
            'event_url': log['event_url']?.toString() ?? ''
          };
        }).toList(); // 응답 데이터를 로그 리스트에 추가

        detectionCount = logs.length; // 감지된 로그 수로 감지 횟수 설정
      } else {
        print('Failed to fetch logs: ${response.body}'); // 오류 메시지 출력
      }
    } catch (e) {
      print('Error fetching logs: $e'); // 예외 발생 시 오류 메시지 출력
    }
  }

  // 서버에 사용자 로그를 삭제 요청하는 메소드
  Future<void> clearLogs() async {
    final String? flaskIp = dotenv.env['FLASK_IP']; // Flask 서버 IP 가져오기
    final String? flaskPort = dotenv.env['FLASK_PORT']; // Flask 서버 포트 가져오기
    final String url =
        'http://$flaskIp:$flaskPort/delete_user_events'; // 로그 삭제 요청 URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // JSON 형식 요청 헤더
        body: jsonEncode({'user_id': currentUserId}), // 사용자 ID 포함하여 POST 요청
      );
      if (response.statusCode == 200) {
        logs.clear(); // 성공 시 로그 리스트 비우기
        detectionCount = 0; // 감지 횟수 초기화
        print('Logs cleared successfully'); // 성공 메시지 출력
      } else {
        print('Failed to clear logs: ${response.body}'); // 오류 메시지 출력
      }
    } catch (e) {
      print('Error clearing logs: $e'); // 예외 발생 시 오류 메시지 출력
    }
  }

  // 특정 로그 삭제하는 메소드
  Future<void> deleteLog(String userId, String timestamp) async {
    final String? flaskIp = dotenv.env['FLASK_IP']; // Flask 서버 IP 가져오기
    final String? flaskPort = dotenv.env['FLASK_PORT']; // Flask 서버 포트 가져오기
    final String url = 'http://$flaskIp:$flaskPort/delete_log'; // 로그 삭제 요청 URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"}, // JSON 형식 요청 헤더
        body: jsonEncode({
          'user_id': userId,
          'timestamp': timestamp
        }), // 삭제할 로그의 사용자 ID 및 타임스탬프 포함하여 POST 요청
      );
      if (response.statusCode == 200) {
        // 성공 시 로그 리스트에서 해당 로그 제거
        logs.removeWhere(
            (log) => log['user_id'] == userId && log['timestamp'] == timestamp);
        print('Log deleted successfully'); // 성공 메시지 출력
      } else {
        print('Failed to delete log: ${response.body}'); // 오류 메시지 출력
      }
    } catch (e) {
      print('Error deleting log: $e'); // 예외 발생 시 오류 메시지 출력
    }
  }

  // 소켓 연결을 정리하는 메소드
  @override
  void onClose() {
    socketManager.disconnect(); // 소켓 연결 해제
    super.onClose(); // 부모 클래스의 onClose 메소드 호출
  }

  // 현재 사용자 ID를 설정하는 메소드
  void setCurrentUserId(String userId) {
    currentUserId = userId;
  }
}
