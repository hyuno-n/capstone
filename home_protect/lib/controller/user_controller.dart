// user_controller.dart
import 'package:get/get.dart';

class UserController extends GetxController {
  var username = ''.obs;

  void setUsername(String value) {
    username.value = value;
  }
}
