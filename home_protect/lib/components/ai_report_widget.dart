import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AiWidget extends StatelessWidget {
  const AiWidget({super.key});

  Widget _reportAlarm1() {
    return Container(
      height: 70,
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
            padding: EdgeInsets.only(left: 8.0, right: 70.0),
            child: Text("2024-05-26"),
          ),
          const Text("움직임 감지"),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: SvgPicture.asset("assets/svg/icons/play_button.svg"),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportAlarm2() {
    return Container(
      height: 70,
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
            padding: EdgeInsets.only(left: 8.0, right: 70),
            child: Text("2024-05-20"),
          ),
          const Text("침입감지"),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: SvgPicture.asset("assets/svg/icons/play_button.svg"),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _reportAlarm1(),
          _reportAlarm2(),
        ],
      ),
    );
  }
}
