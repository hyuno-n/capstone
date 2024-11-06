import 'package:get/get.dart';
import 'package:app/controller/app_controller.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/controller/log_controller.dart';
import 'package:app/provider/camera_provider.dart';

class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(CameraProvider());
    Get.put(AppController());
    Get.put(UserController());
    Get.put(LogController(Get.find<CameraProvider>()));
  }
}
