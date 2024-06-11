import 'package:get/get.dart';

enum RouteName { Monitoring, AI_report, Detection_range, User_page }

class AppController extends GetxService {
  static AppController get to => Get.find();
  RxInt currentIndex = 0.obs;

  void changePageIndex(int index) {
    currentIndex(index);
  }
}
