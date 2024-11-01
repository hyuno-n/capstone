import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../components/notification_manager.dart';
import 'package:app/controller/log_controller.dart';

class SocketManager {
  late IO.Socket socket;
  final NotificationManager notificationManager;
  final LogController logController;
  bool isConnected = false;

  SocketManager(this.notificationManager, this.logController);

  void connectToSocket(String currentUserId) {
    if (isConnected) return;

    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];

    if (flaskIp == null || flaskPort == null) {
      print("FLASK_IP or FLASK_PORT is not set in .env file");
      return;
    }

    final String serverUrl = 'http://$flaskIp:$flaskPort';

    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {'EIO': '3'}
    });

    socket.onConnect((_) {
      print('Connected to Flask server');
      isConnected = true;
    });

    socket.on('push_message', (data) {
      String userId = data['user_id'] ?? "Unknown User";

      if (userId == currentUserId) {
        logController.handleIncomingMessage(data);
        String timestamp =
            data['timestamp'] ?? DateTime.now().toIso8601String();
        DateTime dateTime = DateTime.parse(timestamp);
        String formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

        String eventname = data['eventname'] ?? "New Event";
        String cameraNumber = data['camera_number']?.toString() ?? "N/A";

        String title = "$eventname 발생!";
        String message = "camera_number: $cameraNumber";

        notificationManager.showNotification(title, message);
        logController.fetchLogs(userId);
      }
    });

    socket.onDisconnect((_) {
      print("Disconnected from Flask server");
      isConnected = false;
    });
  }

  void disconnect() {
    if (isConnected) {
      socket.dispose();
      isConnected = false;
    }
  }
}
