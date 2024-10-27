import 'package:get/get.dart';
import 'package:home_protect/controller/app_controller.dart';
import 'package:home_protect/controller/user_controller.dart';
import 'package:home_protect/controller/log_controller.dart';

class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(UserController());
    Get.put(LogController());
  }
}
