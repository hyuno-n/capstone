import 'package:get/get.dart';

class UserController extends GetxController {
  var username = ''.obs;
  var isLoggedIn = false.obs;

  void setUsername(String value) {
    username.value = value;
  }

  void setLoggedIn(bool value) {
    isLoggedIn.value = value;
  }

  String get getUserId => username.value;
}
