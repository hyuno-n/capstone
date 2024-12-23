import 'package:app/pages/first_login.dart';
import 'package:app/provider/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/pages/sign_up_page.dart';
import 'package:app/src/app.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/controller/log_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app/pages/forgot_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Page extends StatelessWidget {
  const Login_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final UserController userController = Get.find();
  final LogController logController = Get.find();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String? flaskIp = dotenv.env['FLASK_IP'];
    final String? flaskPort = dotenv.env['FLASK_PORT'];
    final String url = 'http://$flaskIp:$flaskPort/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // 로그인 상태 설정
        userController.setUsername(_usernameController.text);
        userController.setLoggedIn(true);
        userController.setEmail(data['email']);
        userController.setPhone(data['phone']);
        userController.setName(data['name']);
        logController.setCurrentUserId(_usernameController.text);
        logController.fetchLogs(_usernameController.text);
        logController.connectSocket();
        //CameraProvider에 상태 설정 및 SharedPreferences
        final cameraProvider =
            Provider.of<CameraProvider>(context, listen: false);
        for (var camera in data['cameras']) {
          cameraProvider.addCameraLocally(
            camera['rtsp_url'],
            camera['camera_number'],
            fallDetection: camera['fall_detection_on'],
            fireDetection: camera['fire_detection_on'],
            movementDetection: camera['movement_detection_on'],
            rangeDetection: camera['roi_detection_on'],
          );
        }

        await cameraProvider.saveAllDetectionStatus();

        final prefs = await SharedPreferences.getInstance();
        final String currentUserId = _usernameController.text;
        final bool hasSeenHowToUsePage =
            prefs.getBool('seenHowToUseAppPage_$currentUserId') ?? false;

        if (!hasSeenHowToUsePage) {
          // 첫 로그인 시 HowToUseAppPage를 보여주고 상태를 저장
          await prefs.setBool('seenHowToUseAppPage_$currentUserId', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FirstLogin()),
          );
        } else {
          // 이미 본 경우 바로 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const App()),
          );
        }
      } else {
        Get.snackbar(
          "Login Failed",
          "Failed to login: ${response.body}",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  "assets/images/lock_icon.png",
                  width: 135,
                  height: 135,
                ),
                const SizedBox(height: 15),
                Text(
                  'welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 290,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      userController.setUsername(value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 290,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 170),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
