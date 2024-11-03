import 'package:get/get.dart';

class UserController extends GetxController {
  var username = ''.obs;
  var isLoggedIn = false.obs;
  var email = ''.obs;

  void setUsername(String value) {
    username.value = value;
  }

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
  }

  void setEmail(String value) {
    email.value = value;
  }

  String get getUserId => username.value;
  String get getEmail => email.value;
}
