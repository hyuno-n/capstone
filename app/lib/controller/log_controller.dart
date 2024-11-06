import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/notification_manager.dart';
import '../server/socket_manager.dart';
import 'package:app/provider/camera_provider.dart';

class LogController extends GetxController {
  late NotificationManager notificationManager;
  late SocketManager socketManager;
  var logs = <Map<String, String>>[].obs;
  var videoClips = <Map<String, String>>[].obs;
  int detectionCount = 0;
  int videocount = 0;
  String currentUserId = '';

  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Timer? _retryTimer;
  RxInt newNotificationCount = 0.obs; // 새로운 알림 수 추가

  final CameraProvider cameraProvider;

  LogController(this.cameraProvider);

  @override
  void onInit() {
    super.onInit();
    notificationManager = NotificationManager();
  }

  void connectSocket() {
    socketManager = SocketManager(notificationManager, this, cameraProvider);
    socketManager.connectToSocket(currentUserId);
  }

  void handleIncomingMessage(Map<String, dynamic> data) {
    detectionCount++;
    videocount++;
    String userId = data['user_id'] ?? "Unknown User";
    String timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();
    String eventname = data['eventname'] ?? "New Event";
    String cameraNumber = data['camera_number']?.toString() ?? "N/A";
    String eventUrl = data['event_url'] ?? '';

    logs.add({
      'user_id': userId,
      'timestamp': timestamp,
      'eventname': eventname,
      'camera_number': cameraNumber,
    });

    videoClips.add({
      'user_id': userId,
      'timestamp': timestamp,
      'eventname': eventname,
      'camera_number': cameraNumber,
      'event_url': eventUrl
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
        _handleFetchError(() => fetchLogs(currentUserId));
      }
    } catch (e) {
      _handleFetchError(() => fetchLogs(currentUserId));
    }
  }

  Future<void> fetchVideoClips(String userId) async {
    isLoading.value = true;
    hasError.value = false;

    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url =
        'http://$flaskIp:$flaskPort/get_user_video_clips/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedClips = jsonDecode(response.body);
        videoClips.value = fetchedClips.map((dynamic clip) {
          return {
            'user_id': clip['user_id']?.toString() ?? '',
            'timestamp': clip['timestamp']?.toString() ?? '',
            'eventname': clip['eventname']?.toString() ?? '',
            'camera_number': clip['camera_number']?.toString() ?? '',
            'event_url': clip['event_url']?.toString() ?? ''
          };
        }).toList();
        videocount = videoClips.length;
        isLoading.value = false;
      } else {
        _handleFetchError(() => fetchVideoClips(currentUserId));
      }
    } catch (e) {
      _handleFetchError(() => fetchVideoClips(currentUserId));
    }
  }

  void _handleFetchError(Function fetchFunction) {
    hasError.value = true;
    isLoading.value = false;
    _retryFetch(() => fetchFunction());
  }

  void _retryFetch(Future<void> Function() fetchFunction) {
    _retryTimer?.cancel(); // 이전 타이머를 취소하고
    _retryTimer = Timer(Duration(seconds: 5), fetchFunction); // 5초 후 다시 시도
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
        videoClips.clear();
        detectionCount = 0;
        newNotificationCount.value = 0;
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
        videoClips.removeWhere((video) =>
            video['user_id'] == userId && video['timestamp'] == timestamp);
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
