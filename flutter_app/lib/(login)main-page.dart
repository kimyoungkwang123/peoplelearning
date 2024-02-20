import 'package:flutter/material.dart';
import '/mainpage/Banner.dart';
import '/mainpage/Popular-lectures.dart';
import '/mainpage/sidebar.dart';
import '/mainpage/total-lecture.dart';
import '/mainpage/basket.dart';

class MainPageLogin extends StatelessWidget {
  final Map<String, dynamic> userInfo;

  MainPageLogin({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    String userEmail = userInfo?['userEmail'] ?? 'Unknown';
    String userName = userInfo?['userName'] ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/image/logo.png',
          height: 80,
          width: 100,
        ),
        actions: [
          // 전체 강의
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TotalLecturePage(userInfo: userInfo)),
              );
            },
            child: Text(
              '전체 강의',
              style: TextStyle(color: Colors.black),
            ),
          ),
          // 장바구니 아이콘 버튼
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BasketPage(userInfo: userInfo)),
              );
            },
          ),
        ],
      ),
      drawer: SideBar(
        parentContext: context,
        isLoggedIn: userInfo != null, // 로그인 여부 확인
        userInfo: userInfo, // userInfo 전달
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            BannerSlider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 3, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '인기 강의 추천',
                    style: TextStyle(fontSize: 25),
                  ),
                  Icon(
                    Icons.star,
                    size: 25,
                    color: Colors.yellow,
                  ),
                  Spacer(),
                ],
              ),
            ),
            PopularLectures(),
          ],
        ),
      ),
    );
  }
}
