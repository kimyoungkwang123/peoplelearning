import 'package:flutter/material.dart';
import 'written-board-api.dart';

class WrittenBoardPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  WrittenBoardPage({required this.userInfo});
  @override
  _WrittenBoardPageState createState() => _WrittenBoardPageState();
}

class _WrittenBoardPageState extends State<WrittenBoardPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  String _previousTitle = ''; // 이전에 작성한 제목 저장
  String _previousContent = ''; // 이전에 작성한 내용 저장

  @override
  void initState() {
    super.initState();
    _previousTitle = _titleController.text; // 초기값 설정
    _previousContent = _contentController.text; // 초기값 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '강의 제목을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: null, // 다중 라인 허용
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 취소 버튼을 눌렀을 때의 동작 구현
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 게시글 작성 버튼 눌렀을 때의 동작
                    String title = _titleController.text;
                    String content = _contentController.text;

                    // TODO: WrittenBoardApi를 사용하여 게시글 작성 로직 추가
                    try {
                      await WrittenBoardApi.postWrittenBoard(
                        userEmail: widget.userInfo?['userEmail'] ?? '',
                        boardText: content,
                        boardTitle: title,
                      );

                      // 화면 갱신을 위해 setState 호출
                      setState(() {});

                      // 게시글 작성 완료 후 뒤로 이동
                      Navigator.pop(context);
                    } catch (error) {
                      // 에러 처리
                      print('Error posting written board: $error');
                    }
                  },
                  child: Text('작성하기'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
