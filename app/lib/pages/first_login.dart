import 'package:app/usePage/page_1.dart';
import 'package:app/usePage/page_2.dart';
import 'package:app/usePage/page_3.dart';
import 'package:app/usePage/page_4.dart';
import 'package:app/usePage/page_5.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FirstLogin extends StatefulWidget {
  const FirstLogin({super.key});

  @override
  _FirstLoginState createState() => _FirstLoginState();
}

class _FirstLoginState extends State<FirstLogin> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 500,
            child: PageView(
              controller: _controller,
              children: const [
                Page1(),
                Page2(),
                Page3(),
                Page4(),
                Page5(),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: 5,
            effect: const JumpingDotEffect(
              activeDotColor: Color.fromARGB(255, 24, 24, 24),
              dotColor: Color.fromARGB(255, 165, 165, 165),
              dotHeight: 25,
              dotWidth: 25,
              spacing: 16,
              verticalOffset: 50,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
