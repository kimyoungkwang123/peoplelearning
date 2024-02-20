import 'package:flutter/material.dart';
import 'detail-board-api.dart';
import 'board-like-api.dart';
import 'board-unlike-api.dart';

class DetailBoardPage extends StatefulWidget {
  final int boardID;
  final Map<String, dynamic>? userInfo;

  DetailBoardPage({required this.boardID, this.userInfo});

  @override
  _DetailBoardPageState createState() => _DetailBoardPageState();
}

class _DetailBoardPageState extends State<DetailBoardPage> {
  late Future<Map<String, dynamic>> _detailBoardFuture;

  @override
  void initState() {
    super.initState();
    _fetchDetailBoard(); // 상세 정보를 가져오는 메서드 호출
  }

  // 상세 정보를 다시 가져오는 메서드
  Future<void> _fetchDetailBoard() async {
    try {
      setState(() {
        _detailBoardFuture =
            DetailBoardApi.fetchDetailBoard(widget.boardID.toString());
      });
    } catch (error) {
      print('Error fetching detail board: $error');
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _detailBoardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('로딩 중...'); // 로딩 중일 때
            } else if (snapshot.hasError) {
              return Text('데이터를 불러오는 중 오류가 발생했습니다.'); // 오류 발생 시
            } else {
              final data = snapshot.data!['data'][0];
              final boardDetail = BoardDetail.fromJson(data);
              return Text(boardDetail.boardTitle); // 데이터를 성공적으로 불러온 경우
            }
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailBoardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중일 때
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.')); // 오류 발생 시
          } else {
            final data = snapshot.data!['data'][0];
            final boardDetail = BoardDetail.fromJson(data);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '작성 시간: ${_formatPostTime(boardDetail.boardTime)}',
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye),
                            SizedBox(width: 4.0),
                            Text('조회수'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up),
                              onPressed: () async {
                                // 좋아요 버튼을 눌렀을 때 서버로 좋아요 요청을 보냅니다.
                                await BoardLikeApi.likeBoard(
                                  boardID: widget.boardID, // 게시글 ID
                                  userEmail: widget.userInfo?['userEmail'] ??
                                      '', // 사용자 이메일
                                );

                                _fetchDetailBoard(); // 좋아요 버튼을 누를 때마다 상세 정보를 다시 가져오도록 변경
                              },
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Text('${boardDetail.boardLike}'),
                            ),
                            SizedBox(height: 8.0),
                            IconButton(
                              icon: Icon(Icons.thumb_down),
                              onPressed: () async {
                                // 싫어요 버튼 클릭 시 호출되는 함수
                                await BoardUnlikeApi.unlikeBoard(
                                  boardID: widget.boardID, // 게시글 ID 전달
                                  userEmail: widget.userInfo?['userEmail'] ??
                                      '', // 사용자 이메일 전달
                                );

                                _fetchDetailBoard(); // 싫어요 버튼을 누를 때마다 상세 정보를 다시 가져오도록 변경
                              },
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Text('${boardDetail.boardUnlike}'),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${boardDetail.boardText}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: AnswerWidget(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Future<void> _sendReaction(String reactionType) async {
  //   try {
  //     await BoardLikeApi.likeBoard(
  //       // BoardLikeApi를 사용하도록 수정
  //       boardID: widget.boardID,
  //       userEmail: widget.userInfo?['userEmail'] ?? '',
  //     );

  //     // 리액션을 성공적으로 서버에 전송한 후에 데이터를 다시 불러옴
  //     await _fetchBoardDetail(); // 수정 필요

  //     setState(() {
  //       // UI를 갱신하는 추가적인 작업이 필요한 경우 여기에 작성하세요.
  //     });
  //   } catch (error) {
  //     print('Error sending reaction: $error');
  //   }
  // }

  // Future<void> _fetchBoardDetail() async {
  //   try {
  //     final boardDetail =
  //         await DetailBoardApi.fetchDetailBoard(widget.boardID.toString());

  //     // 데이터를 가져온 후에 적절한 처리를 수행하세요.
  //   } catch (error) {
  //     print('Error fetching board detail: $error');
  //   }
  // }

  String _formatPostTime(DateTime time) {
    String year = time.year.toString().substring(2, 4);
    String month = time.month.toString().padLeft(2, '0');
    String day = time.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

//답변
class Answer {
  final String content;
  final String userName;
  final DateTime time;

  Answer({required this.content, required this.userName, required this.time});
}

class AnswerWidget extends StatefulWidget {
  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  TextEditingController _answerController = TextEditingController();
  List<Answer> answers = [];

  @override
  void initState() {
    super.initState();

    // 직접 3개의 답변을 생성하여 추가
    Answer answer1 = Answer(
      content: '첫 번째 답변입니다.',
      userName: '사용자1',
      time: DateTime(2023, 1, 15),
    );
    Answer answer2 = Answer(
      content: '두 번째 답변입니다.',
      userName: '사용자2',
      time: DateTime(2023, 2, 20),
    );
    Answer answer3 = Answer(
      content: '세 번째 답변입니다.',
      userName: '사용자3',
      time: DateTime(2023, 3, 25),
    );

    answers.addAll([answer1, answer2, answer3]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '답변',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: _answerController,
          decoration: InputDecoration(
            hintText: '답변을 작성해주세요.',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            String answerContent = _answerController.text.trim();

            if (answerContent.isNotEmpty) {
              setState(() {
                // 사용자 이름은 임시로 "사용자"로 지정
                Answer newAnswer = Answer(
                  content: answerContent,
                  userName: "사용자",
                  time: DateTime.now(),
                );

                answers.add(newAnswer);

                // 시간순으로 정렬
                answers.sort((a, b) => b.time.compareTo(a.time));

                _answerController.clear();
              });
            } else {
              // 답변이 비어 있을 경우 경고 팝업 표시
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('경고'),
                    content: Text('답변을 작성해주세요.'),
                    actions: [
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
          child: Text('답변 추가'),
        ),
        SizedBox(height: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: answers.map((answer) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(width: 8.0),
                      Text('${answer.userName}'),
                      SizedBox(width: 8.0),
                      Text('${_formatAnswerTime(answer.time)}'),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 80,
                        ),
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(answer.content),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatAnswerTime(DateTime time) {
    String year = time.year.toString().substring(2, 4);
    String month = time.month.toString().padLeft(2, '0');
    String day = time.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
