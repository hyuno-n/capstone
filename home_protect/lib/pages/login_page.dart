import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Get 패키지 임포트
import 'package:home_protect/pages/sign_up_page.dart';
import 'package:home_protect/src/app.dart'; // App 페이지 임포트
import 'package:home_protect/controller/user_controller.dart'; // UserController 임포트

class Login_Page extends StatelessWidget {
  const Login_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // CupertinoApp 대신 MaterialApp 사용
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Login"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 170),
            SizedBox(
              width: 280,
              child: CupertinoTextField(
                placeholder: 'Username',
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.lightBackgroundGray,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onChanged: (value) {
                  userController.setUsername(value);
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 280,
              child: CupertinoTextField(
                placeholder: 'Password',
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                obscureText: true,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.lightBackgroundGray,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 115),
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const App()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 7),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Sign_up_Page()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
