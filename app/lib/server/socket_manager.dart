import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../components/notification_manager.dart';
import 'package:app/controller/log_controller.dart';
import 'package:app/provider/camera_provider.dart';

/// `SocketManager` 클래스는 서버와의 소켓 연결을 관리하고,
/// 실시간 이벤트 메시지를 수신하여 알림 및 로그 처리에 사용됩니다.
class SocketManager {
  late IO.Socket socket; // Socket.io 클라이언트 소켓 인스턴스
  final NotificationManager notificationManager; // 알림 관리를 위한 인스턴스
  final LogController logController; // 로그 관리를 위한 인스턴스
  final CameraProvider cameraProvider; // CameraProvider 인스턴스 추가
  bool isConnected = false; // 소켓 연결 상태를 나타내는 플래그

  // 생성자: `NotificationManager`, `LogController`, `CameraProvider` 인스턴스를 받아 설정
  SocketManager(
    this.notificationManager,
    this.logController,
    this.cameraProvider,
  );

  /// 서버에 소켓 연결을 설정하고 이벤트를 수신합니다.
  /// 이미 연결된 경우 재연결을 시도하지 않습니다.
  void connectToSocket(String currentUserId) {
    if (isConnected) return; // 이미 연결된 경우 종료

    // 환경 변수에서 Flask 서버의 IP와 포트를 가져옵니다.
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];

    // 환경 변수 설정이 누락된 경우 오류 메시지를 출력하고 종료
    if (flaskIp == null || flaskPort == null) {
      print("FLASK_IP or FLASK_PORT is not set in .env file");
      return;
    }

    // 서버 URL 생성
    final String serverUrl = 'http://$flaskIp:$flaskPort';

    // 서버와의 소켓 연결을 설정
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'], // 웹소켓을 통한 통신 사용
      'autoConnect': true, // 자동으로 연결 시도
      'extraHeaders': {'EIO': '3'} // Socket.io 버전 3 사용
    });

    // 연결 성공 시 실행되는 이벤트 핸들러
    socket.onConnect((_) {
      print('Connected to Flask server'); // 연결 성공 메시지 출력
      isConnected = true;
    });

    // 'push_message' 이벤트 수신 시 실행되는 핸들러
    socket.on('push_message', (data) {
      String userId = data['user_id'] ?? "Unknown User"; // 수신한 메시지의 사용자 ID

      // 현재 사용자 ID와 일치하는 경우 메시지 처리
      if (userId == currentUserId) {
        // 로그 컨트롤러로 메시지 전달
        logController.handleIncomingMessage(data);

        // 수신한 타임스탬프를 포맷팅하여 DateTime 객체로 변환
        String timestamp =
            data['timestamp'] ?? DateTime.now().toIso8601String();
        DateTime dateTime = DateTime.parse(timestamp);
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

        // 이벤트명과 카메라 번호 설정
        String eventname = data['eventname'] ?? "New Event";
        int? cameraNumber = data['camera_number'];
        String cameraIndexMessage = '';

        // cameraNumber가 있을 경우 cameraIndex를 CameraProvider에서 가져옴
        if (cameraNumber != null) {
          int cameraIndex = cameraProvider.getCameraIndex(cameraNumber) + 1;
          cameraIndexMessage = " $cameraIndex";
        }

        // 알림 제목 및 메시지 생성
        String title = "MVCCTV";
        String message = "📷camera$cameraIndexMessage에서 $eventname이 발생하였습니다.";

        // 알림 매니저를 통해 알림을 화면에 표시
        notificationManager.showNotification(title, message);

        // 새로운 로그를 가져와서 업데이트
        logController.fetchLogs(userId);
      }
    });

    // 연결 해제 시 실행되는 이벤트 핸들러
    socket.onDisconnect((_) {
      print("Disconnected from Flask server"); // 연결 해제 메시지 출력
      isConnected = false;
    });
  }

  /// 서버와의 소켓 연결을 해제합니다.
  void disconnect() {
    if (isConnected) {
      socket.dispose(); // 소켓 리소스 해제
      isConnected = false;
    }
  }
}
