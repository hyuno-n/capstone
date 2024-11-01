import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/pages/sign_up_page.dart';
import 'package:app/src/app.dart';
import 'package:app/controller/user_controller.dart';
import 'package:app/controller/log_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        userController.setUsername(_usernameController.text);
        userController.setLoggedIn(true);
        logController.setCurrentUserId(_usernameController.text);
        logController.fetchLogs(_usernameController.text);

        logController.connectSocket();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const App()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login: ${response.body}')),
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
            child: Column(
              children: [
                const SizedBox(height: 80),
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),
                //welcome back, you've been missed!
                Text(
                  'welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                //username textfield

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

                //password textfield

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
                //forgot password?

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 51.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                //sign in  button

                const SizedBox(height: 25),

                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      // 로그인 버튼
                      Container(
                        width: double.infinity, // 버튼을 전체 너비로 확장
                        decoration: BoxDecoration(
                          color: Colors.black, // 버튼 배경색을 검정색으로 설정
                          borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                        ),
                        child: ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // ElevatedButton의 기본 배경색 제거
                            shadowColor: Colors.transparent, // 그림자 제거
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                                fontSize: 20, color: Colors.white), // 텍스트 색상 설정
                          ),
                        ),
                      ), // 버튼 간격
                      // 회원가입 버튼
                      //Container(
                      //  width: double.infinity, // 버튼을 전체 너비로 확장
                      //  decoration: BoxDecoration(
                      //    color: Colors.black, // 버튼 배경색을 검정색으로 설정
                      //    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                      //  ),
                      //  child: TextButton(
                      //    onPressed: () {
                      //      Navigator.push(
                      //        context,
                      //        MaterialPageRoute(
                      //            builder: (context) => const SignUpPage()),
                      //      );
                      //    },
                      //    child: const Text(
                      //      'Sign up',
                      //      style: TextStyle(
                      //          fontSize: 15, color: Colors.white), // 텍스트 색상 설정
                      //    ),
                      //  ),
                      //),
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
                        // 회원가입 페이지로 이동하는 로직 추가
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
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

            //not a member? register now
          ),
        ));
    //return Center(
    //  child: Padding(
    //    padding: const EdgeInsets.all(16.0),
    //    child: SingleChildScrollView(
    //      child: Column(
    //        mainAxisSize: MainAxisSize.min,
    //        children: <Widget>[
    //          const SizedBox(height: 170),
    //          SizedBox(
    //            width: 280,
    //            child: TextField(
    //              controller: _usernameController,
    //              decoration: InputDecoration(
    //                hintText: 'Username',
    //                border: OutlineInputBorder(
    //                  borderRadius: BorderRadius.circular(8.0),
    //                ),
    //              ),
    //              onChanged: (value) {
    //                userController.setUsername(value);
    //              },
    //            ),
    //          ),
    //          const SizedBox(height: 10),
    //          SizedBox(
    //            width: 280,
    //            child: TextField(
    //              controller: _passwordController,
    //              decoration: InputDecoration(
    //                hintText: 'Password',
    //                border: OutlineInputBorder(
    //                  borderRadius: BorderRadius.circular(8.0),
    //                ),
    //              ),
    //              obscureText: true,
    //            ),
    //          ),
    //          const SizedBox(height: 115),
    //          SizedBox(
    //            width: 280,
    //            child: Column(
    //              children: [
    //                ElevatedButton(
    //                  onPressed: () => _login(context),
    //                  child: const Text(
    //                    'Login',
    //                    style: TextStyle(fontSize: 20),
    //                  ),
    //                ),
    //                const SizedBox(height: 7),
    //                TextButton(
    //                  onPressed: () {
    //                    Navigator.push(
    //                      context,
    //                      MaterialPageRoute(
    //                          builder: (context) => const SignUpPage()),
    //                    );
    //                  },
    //                  child: const Text(
    //                    'Sign up',
    //                    style: TextStyle(fontSize: 15),
    //                  ),
    //                ),
    //                const SizedBox(height: 7),
    //                TextButton(
    //                  onPressed: () {
    //                    Navigator.push(
    //                      context,
    //                      MaterialPageRoute(builder: (context) => const App()),
    //                    );
    //                  },
    //                  child: const Text(
    //                    'Go to Home',
    //                    style: TextStyle(fontSize: 15),
    //                  ),
    //                ),
    //              ],
    //            ),
    //          ),
    //        ],
    //      ),
    //    ),
    //  ),
    //);
  }
}
