import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_protect/binding/init_binding.dart';
import 'package:home_protect/pages/splash_screen.dart';
import 'package:home_protect/src/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        GetPage(name: "/", page: () => const App()),
        GetPage(name: "/splash", page: () => const SplashScreen()),
      ],
    );
  }
}
