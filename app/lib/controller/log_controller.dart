import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/notification_manager.dart';
import '../server/socket_manager.dart';

class LogController extends GetxController {
  late NotificationManager notificationManager;
  late SocketManager socketManager;
  var logs = <Map<String, String>>[].obs;
  int detectionCount = 0;
  String currentUserId = '';

  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Timer? _retryTimer;
  RxInt newNotificationCount = 0.obs; // 새로운 알림 수 추가

  @override
  void onInit() {
    super.onInit();
    notificationManager = NotificationManager();
  }

  void connectSocket() {
    socketManager = SocketManager(notificationManager, this);
    socketManager.connectToSocket(currentUserId);
  }

  void handleIncomingMessage(Map<String, dynamic> data) {
    detectionCount++;
    String userId = data['user_id'] ?? "Unknown User";
    String timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    String eventname = data['eventname'] ?? "New Event";
    String cameraNumber = data['camera_number']?.toString() ?? "N/A";
    String eventUrl = data['event_url'] ?? '';

    // 로그 리스트에 새로운 이벤트 추가
    logs.add({
      'user_id': userId,
      'timestamp': timestamp,
      'eventname': eventname,
      'camera_number': cameraNumber,
      'event_url': eventUrl,
    });

    // 새로운 알림 수 증가
    newNotificationCount.value++;
  }

  Future<void> fetchLogs(String userId) async {
    currentUserId = userId;
    isLoading.value = true;
    hasError.value = false;

    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/get_user_events/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedLogs = jsonDecode(response.body);
        logs.value = fetchedLogs.map((dynamic log) {
          return {
            'user_id': log['user_id']?.toString() ?? '',
            'timestamp': log['timestamp']?.toString() ?? '',
            'eventname': log['eventname']?.toString() ?? '',
            'camera_number': log['camera_number']?.toString() ?? '',
            'event_url': log['event_url']?.toString() ?? ''
          };
        }).toList();

        detectionCount = logs.length;
        isLoading.value = false;
      } else {
        _handleFetchError();
      }
    } catch (e) {
      _handleFetchError();
    }
  }

  void _handleFetchError() {
    hasError.value = true;
    isLoading.value = false;

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: 5), () {
      fetchLogs(currentUserId);
    });
  }

  Future<void> clearLogs() async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/delete_user_events';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'user_id': currentUserId}),
      );
      if (response.statusCode == 200) {
        logs.clear();
        detectionCount = 0;
        newNotificationCount.value = 0; // 알림 수 리셋
        print('Logs cleared successfully');
      } else {
        print('Failed to clear logs: ${response.body}');
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }

  Future<void> deleteLog(String userId, String timestamp) async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/delete_log';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'user_id': userId, 'timestamp': timestamp}),
      );
      if (response.statusCode == 200) {
        logs.removeWhere(
            (log) => log['user_id'] == userId && log['timestamp'] == timestamp);
        print('Log deleted successfully');
      } else {
        print('Failed to delete log: ${response.body}');
      }
    } catch (e) {
      print('Error deleting log: $e');
    }
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    socketManager.disconnect();
    super.onClose();
  }

  void setCurrentUserId(String userId) {
    currentUserId = userId;
  }

  // 알림 수를 리셋하는 메소드 추가
  void resetNotificationCount() {
    newNotificationCount.value = 0;
  }
}
