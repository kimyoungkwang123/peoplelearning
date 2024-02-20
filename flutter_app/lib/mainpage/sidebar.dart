import 'package:flutter/material.dart';
import 'package:flutter_app/mainpage/user/Purchase%20history.dart';
import 'package:flutter_app/mainpage/login-page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main-page.dart';
import 'signup-page.dart';
import 'user/mylecture.dart';
import 'user/myboard.dart';
import 'user/search-lecture.dart';
import 'user/update-user.dart';
import 'user/written-board.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sidebar-category-api.dart';

class SideBar extends StatefulWidget {
  final BuildContext parentContext;
  final bool isLoggedIn;
  final Map<String, dynamic>? userInfo;

  SideBar({
    required this.parentContext,
    required this.isLoggedIn,
    this.userInfo,
  });

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  TextEditingController searchController = TextEditingController();
  String? _selectedCategory;
  int? _selectedCategoryId; // 선택한 카테고리 ID를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: ListView(
        children: [
          Container(
            height: 110,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
            ),
            child: Column(
              children: [
                if (widget.isLoggedIn) ...{
                  GestureDetector(
                    onTap: () {
                      RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      Offset offset = renderBox.localToGlobal(Offset.zero);

                      // 팝업 메뉴 표시
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx + renderBox.size.width / 2, // 오른쪽으로
                          offset.dy + renderBox.size.height, // 아래쪽으로
                          0,
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                // '내 강의' 동작 처리
                                Navigator.pop(context); // 팝업 메뉴 닫기
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyLecturePage(
                                          userInfo: widget.userInfo)),
                                );
                              },
                              child: Text('내 강의'),
                            ),
                          ),
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                // '구매 내역' 동작 처리
                                Navigator.pop(context); // 팝업 메뉴 닫기
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BuyPage(userInfo: widget.userInfo)),
                                );
                              },
                              child: Text('구매 내역'),
                            ),
                          ),
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                // '작성한 게시글' 동작 처리
                                Navigator.pop(context); // 팝업 메뉴 닫기
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MyBoard(userInfo: widget.userInfo)),
                                );
                              },
                              child: Text('작성한 게시글'),
                            ),
                          ),
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                // '내 정보 수정' 동작 처리
                                Navigator.pop(context); // 팝업 메뉴 닫기
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateUserPage(
                                          userInfo: widget.userInfo)),
                                );
                              },
                              child: Text('내 정보 수정'),
                            ),
                          ),

                          //게시글 작성
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                // '게시글 작성' 동작 처리
                                Navigator.pop(context); // 팝업 메뉴 닫기
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WrittenBoardPage(
                                          userInfo: widget.userInfo)),
                                );
                              },
                              child: Text('게시글 작성'),
                            ),
                          ),

                          //로그아웃
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {
                                onLogoutPressed(context); // 로그아웃 메서드 호출
                              },
                              child: Text('로그아웃'),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.account_circle,
                            size: 40.0,
                            color: Colors.blue,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${widget.userInfo!['userName']}님 환영합니다',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                } else ...{
                  Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 세로 방향 중앙 정렬
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // 가로 방향 중앙 정렬
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              child: Text(
                                '로그인 후 이용해주세요',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                }
              ],
            ),
          ),

          SizedBox(height: 15),
          // 선택한 카테고리 ID를 저장할 변수

          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: '검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          FutureBuilder<List<Category>>(
            future: fetchCategoryList(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // 에러 발생 시 메시지 표시
              } else {
                List<DropdownMenuItem<String>> dropdownItems =
                    snapshot.data!.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.categoryName,
                    child: Text(category.categoryName),
                  );
                }).toList();

                return Container(
                  width: 140,
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items: dropdownItems,
                    onChanged: (String? selectedCategory) {
                      setState(() {
                        _selectedCategory =
                            selectedCategory; // 선택한 카테고리 이름 업데이트
                        // 선택한 카테고리 ID를 찾아 _selectedCategoryId에 저장
                        _selectedCategoryId = snapshot.data!
                            .firstWhere(
                              (category) =>
                                  category.categoryName == selectedCategory,
                            )
                            .categoryID;
                        print('선택한 카테고리: $_selectedCategory');
                      });
                    },
                    hint: Text('카테고리 선택'),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              String searchText = searchController.text;

              // 선택한 카테고리 ID를 검사하여 null인지 확인 후 검색 결과 페이지로 전달
              if (_selectedCategoryId != null) {
                Navigator.pop(context); // 사이드바를 닫음
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchLecturePage(
                      lectureTitle: searchText,
                      categoryID: _selectedCategoryId!,
                      userInfo: widget.userInfo,
                    ),
                  ),
                );

                print(
                  '검색어: $searchText, 선택한 카테고리 ID: $_selectedCategoryId',
                );
              } else {
                // 선택한 카테고리가 없는 경우에 대한 처리
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('알림'),
                      content: Text('카테고리를 선택하세요.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('확인'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text('검색'),
          ),

          SizedBox(height: 15), // 간격 조절

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () async {
              // Home 버튼을 클릭했을 때의 동작
              Navigator.pop(widget.parentContext); // 사이드바를 닫음
            },
          ),
        ],
      ),
    );
  }

  void onLogoutPressed(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token'); // 토큰 삭제

    // 토큰이 삭제되었는지 여부 확인
    bool isTokenDeleted = !(prefs.containsKey('token'));

    if (isTokenDeleted) {
      print('토큰이 삭제되었습니다.');
    } else {
      print('토큰 삭제에 실패했습니다.');
    }

    // 로그아웃 후 로그인 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(),
      ),
    );
  }
}
