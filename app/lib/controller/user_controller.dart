import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserController extends GetxController {
  var username = ''.obs;
  var isLoggedIn = false.obs;
  var email = ''.obs;
  var phone = ''.obs;

  void setUsername(String value) {
    username.value = value;
  }

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
  }

  void setEmail(String value) {
    email.value = value;
  }

  void setPhone(String value) {
    phone.value = value;
  }

  String get getUserId => username.value;
  String get getEmail => email.value;
  String get getPhone => phone.value;

  Future<void> deleteAccount() async {
    if (username.value.isEmpty) {
      return;
    }

    final String flaskIp = dotenv.env['FLASK_IP'] ?? 'localhost';
    final String flaskPort = dotenv.env['FLASK_PORT'] ?? '5000';
    final userId = username.value;
    final String url = 'http://$flaskIp:$flaskPort/delete_user/$userId';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        // 계정 정보 초기화
        setUsername('');
        setLoggedIn(false);
        setEmail('');
        setPhone('');

        // 탈퇴 성공 메시지 표시
        Get.snackbar("탈퇴 완료", "계정이 성공적으로 삭제되었습니다.");
      } else {
        // 탈퇴 실패 메시지 표시
        print("Failed to delete user: ${response.statusCode}");
        Get.snackbar("탈퇴 실패", "계정 삭제에 실패했습니다. 다시 시도해주세요.");
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      print("Error occurred while deleting account: $e");
      Get.snackbar("탈퇴 실패", "계정 삭제 중 오류가 발생했습니다. 네트워크를 확인하고 다시 시도해주세요.");
    }
  }
}
