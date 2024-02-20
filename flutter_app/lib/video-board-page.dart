import 'package:flutter/material.dart';
import 'detail-board.dart';
import 'video-board-api.dart';

class VideoBoardPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  VideoBoardPage({
    this.userInfo,
  });
  @override
  _VideoBoardPageState createState() => _VideoBoardPageState();
}

class _VideoBoardPageState extends State<VideoBoardPage> {
  // 서버에서 가져온 게시글 데이터를 저장할 변수
  late List<BoardPost> posts = [];
  //검색
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBoardData();
  }

  // 서버에서 게시글 데이터를 가져오는 함수
  Future<void> _fetchBoardData() async {
    try {
      // 서버 연동을 통해 게시글 데이터를 가져옵니다.
      final List<BoardPost> boardData = await VideoBoardApi.fetchBoardData();
      // 가져온 데이터를 BoardPost 객체로 변환하여 posts에 저장합니다.
      setState(() {
        posts = boardData;
      });
    } catch (error) {
      // 에러 처리
      print('Failed to fetch board data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                // 각 게시글에 해당하는 GestureDetector를 생성하여 클릭 이벤트를 처리합니다.
                return GestureDetector(
                  onTap: () {
                    // 클릭 이벤트 처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailBoardPage(
                            boardID: posts[index].boardID,
                            userInfo: widget.userInfo), // boardID 전달
                      ),
                    );
                  },
                  child: VideoBoard(
                    boardPost: posts[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoBoard extends StatelessWidget {
  final BoardPost boardPost;

  const VideoBoard({Key? key, required this.boardPost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatPostTime(boardPost.boardTime);

    return Container(
      margin: EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.account_circle),
                  SizedBox(width: 8.0),
                  Text(boardPost.userName),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                boardPost.boardTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                boardPost.boardText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 4.0),
                  Text(formattedTime), // 수정된 부분
                  Spacer(),
                  Icon(Icons.thumb_up),
                  Text(boardPost.boardLike.toString()),
                  SizedBox(width: 8.0),
                  Icon(Icons.remove_red_eye),
                  Text(boardPost.boardCount.toString()),
                  SizedBox(width: 8.0),
                  Icon(Icons.comment),
                  Text(boardPost.commentCount.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPostTime(DateTime time) {
    String year = time.year.toString().substring(2, 4);
    String month = time.month.toString().padLeft(2, '0');
    String day = time.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
