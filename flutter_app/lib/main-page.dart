import 'package:flutter/material.dart';
import '/mainpage/login-page.dart';
import '/mainpage/signup-page.dart';
import '/mainpage/Banner.dart';
import '/mainpage/Popular-lectures.dart';
import '/mainpage/sidebar.dart';
import '/mainpage/total-lecture.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/image/logo.png', // 로고 이미지 파일 경로
          height: 80, // 로고 이미지의 높이 조절
          width: 100, // 너비도 조절하려면 width 속성 추가
        ),
        actions: [
          //전체 강의
          TextButton(
            onPressed: () {
              // LoginPage 클래스를 가져와서 입력폼 구현
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TotalLecturePage(userInfo: null)),
              );
            },
            child: Text(
              '전체 강의',
              // 글자색을 검은색으로 지정
              style: TextStyle(color: Colors.black),
            ),
          ),
          // 로그인 버튼
          TextButton(
            onPressed: () {
              // LoginPage 클래스를 가져와서 입력폼 구현
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text(
              '로그인',
              // 글자색을 검은색으로 지정
              style: TextStyle(color: Colors.black),
            ),
          ),
          // 회원가입 버튼
          TextButton(
            onPressed: () {
              // SignupPage 클래스를 가져와서 입력폼 구현
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: Text(
              '회원가입',
              // 글자색을 검은색으로 지정
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      drawer: SideBar(parentContext: context, isLoggedIn: false),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            BannerSlider(),
            SizedBox(height: 30),
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
            // 다른 내용을 추가할 수 있음
          ],
        ),
      ),
    );
  }
}
