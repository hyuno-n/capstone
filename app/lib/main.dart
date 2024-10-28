import 'package:app/provider/roi_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:app/binding/init_binding.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => RoiProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        fontFamily: 'Pretendard', // 기본 폰트를 Pretendard로 설정
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
