import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_protect/components/drawer_widget.dart';
import 'package:home_protect/components/enddrawer_widget.dart';

class Detection_range extends StatefulWidget {
  const Detection_range({super.key});

  @override
  _Detection_range createState() => _Detection_range();
}

class _Detection_range extends State<Detection_range> {
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  Widget _detection_item1() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              "쓰러짐 감지",
              style: TextStyle(fontSize: 15.5),
            ),
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  CupertinoSwitch(
                    value: _isChecked1,
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked1 = value ?? false;
                        // switch를 true로 바꿀떄 나타나는 알림.
                        if (_isChecked1) {
                          showDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text("Detection range"),
                              content: const Text("쓰러짐 감지 ON?"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text("Don't Allow"),
                                  onPressed: () {
                                    setState(() {
                                      _isChecked1 = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text("Allow"),
                                  onPressed: () {
                                    // Your action here
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _detection_item2() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              "침입 감지",
              style: TextStyle(fontSize: 15.5),
            ),
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  CupertinoSwitch(
                    value: _isChecked2,
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked2 = value ?? false;
                        // switch를 true로 바꿀떄 나타나는 알림.
                        if (_isChecked2) {
                          showDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text("Detection range"),
                              content: const Text("침입 감지 ON?"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text("Don't Allow"),
                                  onPressed: () {
                                    setState(() {
                                      _isChecked2 = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text("Allow"),
                                  onPressed: () {
                                    // Your action here
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.2,
        title: const Text(
          "Detection range",
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
      body: Container(
        child: Column(
          children: [
            _detection_item1(),
            _detection_item2(),
          ],
        ),
      ),
    );
  }
}
