import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_protect/controller/user_controller.dart'; // UserController 임포트

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => UserAccountsDrawerHeader(
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('images/user_profile.png'),
                  backgroundColor: Colors.white,
                ),
                accountName: Text(userController.username.value),
                accountEmail: const Text('lay_down?@gmail.com'),
                onDetailsPressed: () {
                  print('arrow is clicked');
                },
                otherAccountsPictures: const [
                  CircleAvatar(
                    backgroundImage: AssetImage('images/user_profile.png'),
                    backgroundColor: Colors.white,
                  ),
                ],
                decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    )),
              )),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.grey[850],
            ),
            title: const Text('Home'),
            onTap: () {
              print('Home is clicked !');
            },
            trailing: const Icon(Icons.add),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.grey[850],
            ),
            title: const Text('Setting'),
            onTap: () {
              print('Setting is clicked !');
            },
            trailing: const Icon(Icons.add),
          ),
          ListTile(
            leading: Icon(
              Icons.question_answer,
              color: Colors.grey[850],
            ),
            title: const Text('Q&A'),
            onTap: () {
              print('Q&A is clicked !');
            },
            trailing: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
