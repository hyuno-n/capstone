import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';

// ignore: camel_case_types
class User_page extends StatelessWidget {
  const User_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.2,
        title: const Text(
          "User page",
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset("assets/svg/icons/menu_upbar.svg"),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: SvgPicture.asset("assets/svg/icons/alarm_upbar.svg"),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      endDrawer: const EndDrawerWidget(),
      body: const Center(
        child: Text("User page"),
      ),
    );
  }
}
