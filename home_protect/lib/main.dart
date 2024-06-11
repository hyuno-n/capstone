import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_protect/binding/init_binding.dart';
import 'package:home_protect/pages/login_page.dart';
import 'package:home_protect/pages/splash_screen.dart';
import 'package:home_protect/controller/user_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UserController()); // UserController 등록

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Protect App',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: InitBinding(),
      initialRoute: "/splash",
      getPages: [
        GetPage(name: "/", page: () => const Login_Page()),
        GetPage(name: "/splash", page: () => const SplashScreen()),
      ],
    );
  }
}
