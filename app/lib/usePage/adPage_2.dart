import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class AdPage_2 extends StatelessWidget {
  const AdPage_2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지
            Image.asset(
              'assets/images/ad_page_2.jpg',
              fit: BoxFit.cover,
            ),
            // 반투명 오버레이
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            // 텍스트 오버레이
            const Row(
              children: [
                SizedBox(
                  width: 25,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      "아래 카메라를 추가하여",
                      style: TextStyle(
                        color: Colors.white,
                        //fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "지금 바로 안전관리를 시작해보세요!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    Text(
                      "감지가 발견되면 즉각적인 알림과 영상클립이 저장됩니다.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
