import 'package:app/usePage/page_1.dart';
import 'package:app/usePage/page_2.dart';
import 'package:app/usePage/page_3.dart';
import 'package:app/usePage/page_4.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HowToUseAppPage extends StatefulWidget {
  const HowToUseAppPage({super.key});

  @override
  _HowToUseAppPageState createState() => _HowToUseAppPageState();
}

class _HowToUseAppPageState extends State<HowToUseAppPage> {
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
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: 4,
            effect: JumpingDotEffect(
              activeDotColor: const Color.fromARGB(255, 24, 24, 24),
              dotColor: const Color.fromARGB(255, 165, 165, 165),
              dotHeight: 30,
              dotWidth: 30,
              spacing: 16,
              verticalOffset: 50,
            ),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
