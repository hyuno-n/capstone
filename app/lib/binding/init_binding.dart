import 'package:get/get.dart';
import 'package:app/controller/app_controller.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/controller/log_controller.dart';

class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(UserController());
    Get.put(LogController());
  }
}
