import 'package:flutter/material.dart';
import 'dart:async';

class BannerSlider extends StatefulWidget {
  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final List<String> images = ['c.png', 'flutter.png', 'kakaopay.png'];
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0; // 현재 보여지고 있는 페이지의 인덱스

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.asset(
                'assets/image/${images[index]}',
                fit: BoxFit.contain,
              );
            },
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 왼쪽 화살표
            IconButton(
              //왼쪽 위 오른쪽 아래 순으로 패딩
              padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                // 왼쪽 페이지로 이동
                _pageController.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            // 페이지 표시 아이콘들
            Row(
              children: List.generate(
                images.length,
                (index) => Padding(
                  padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: index == currentPage ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            // 오른쪽 화살표
            IconButton(
              padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                // 오른쪽 페이지로 이동
                _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    const Duration duration = Duration(seconds: 5); // 5초 간격으로 설정

    Timer.periodic(duration, (Timer timer) {
      if (_pageController.page == images.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
