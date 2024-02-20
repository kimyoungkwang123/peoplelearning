import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'written-board.dart';
import 'myboard-api.dart';

class MyBoard extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  MyBoard({required this.userInfo});
  @override
  _MyBoardState createState() => _MyBoardState();
}

class _MyBoardState extends State<MyBoard> {
  List<Board> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      List<Board> fetchedPosts = await myboardAPI.fetchLectures(
        widget.userInfo?['userEmail'],
        userInfo: widget.userInfo,
      );
      setState(() {
        posts = fetchedPosts;
      });
    } catch (error) {
      print('Error fetching posts: $error');
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('작성한 게시판'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // 새로고침 버튼을 눌렀을 때의 동작
              _fetchPosts(); // 게시글 목록을 새로 불러오는 메서드 호출
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return buildPostCard(posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 게시글 작성 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    WrittenBoardPage(userInfo: widget.userInfo)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildPostCard(Board post) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.boardTitle, // 게시글 제목을 표시합니다.
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              post.boardText, // 게시글 내용을 표시합니다.
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '작성 일자: ${formatDate(post.boardTime)}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 18),
                    SizedBox(width: 4.0),
                    Text('${post.boardLike}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye, size: 18),
                    SizedBox(width: 4.0),
                    Text('${post.boardCount}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment, size: 18),
                    SizedBox(width: 4.0),
                    Text('${post.boardUnlike}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
