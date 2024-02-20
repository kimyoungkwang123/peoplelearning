// detail-lecture-page.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'detail-lecture-api.dart';
import 'ChapterListPage.dart';
import 'payment.dart';
import 'detail-lecture-api.dart';
import 'basket-add-api.dart';

class DetailLecturePage extends StatefulWidget {
  final int lectureID;
  final int categoryId;
  final Map<String, dynamic>? userInfo;

  DetailLecturePage({
    required this.lectureID,
    required this.categoryId,
    this.userInfo,
  });

  @override
  _DetailLecturePageState createState() => _DetailLecturePageState();
}

class _DetailLecturePageState extends State<DetailLecturePage> {
  late Future<DetailLectureData> _futureDetailLecture;
  late String selectedContent = "";

  @override
  void initState() {
    super.initState();
    _futureDetailLecture = DetailLectureApi.fetchDetailLecture(
        widget.lectureID, widget.userInfo?['userEmail']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강의 상세 정보'),
      ),
      body: FutureBuilder<DetailLectureData>(
        future: _futureDetailLecture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중일 때의 UI
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // 에러 발생 시의 UI
            return Text('에러 발생: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            // 데이터가 없는 경우의 UI
            return Text('데이터가 없습니다.');
          } else {
            // 데이터가 정상적으로 로드된 경우의 UI
            DetailLectureData data = snapshot.data!;
            return buildDetailLectureUI(data);
          }
        },
      ),
    );
  }

  Widget buildDetailLectureUI(DetailLectureData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.lectureInfo.lectureTitle,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Row(children: [
            _buildStarRating(data.lectureInfo.average_scope ?? 0),
            Text('(${data.lectureInfo.average_scope ?? 0})'),
            IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () async {
                // 서버에 장바구니 추가 요청 보내기
                final userEmail = widget.userInfo?['userEmail']; // 사용자 이메일
                final lectureID = widget.lectureID; // 추가할 강의의 ID를 여기에 지정

                final result = await addToBasket(userEmail, lectureID);

                if (result['success']) {
                  // 성공적으로 장바구니에 추가되었을 때
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Success'),
                        content: Text(result['message']),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // 실패했을 때
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text(result['error']),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ]),
          SizedBox(height: 8.0),
          Row(
            children: [
              CircleAvatar(
                child:
                    Icon(Icons.account_circle, size: 35.0, color: Colors.black),
                backgroundColor: Colors.transparent, // 배경 없음
              ),
              Text(
                '${data.instructorInfo.instructorName}',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Image.asset(
            'assets/image/${data.lectureInfo.Lecture_image_URL}',
            width: double.infinity,
            height: 200.0,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 8.0),
          Text(
            '가격: ${data.lectureInfo.price} 원',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  '강의 설명',
                  data.lectureInfo.lectureText,
                  isPurchased: 1, // 강의 설명은 언제나 활성화
                ),
              ),
              Expanded(
                child: _buildButton(
                  '강의 목차',
                  data.lectureContentTitle
                      .map((title) => title.contentTitle)
                      .join('\n'),
                  isPurchased: 1,
                ),
              ),
              Expanded(
                child: _buildButton(
                  '강사 소개',
                  data.instructorInfo.instructorText,
                  isPurchased: 1, // 강사 소개는 언제나 활성화
                ),
              ),
              Expanded(
                child: _buildButton(
                  '강의 자료',
                  data.lectureInfo.lecture_materialsType.toString(),
                  isPurchased: data.lectureMaterialsActive.ispurchased == 1
                      ? 1
                      : 0, // 결제 여부에 따라 활성화
                ),
              ),
            ],
          ),
          Text(
            selectedContent,
            style: TextStyle(fontSize: 16.0),
          ),
          Container(
            margin: EdgeInsets.only(top: 130.0), // 상단 마진 추가
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                // 강의 시청 또는 결제하기 버튼 동작 추가
                if (data.lectureMaterialsActive.ispurchased == 1) {
                  // 강의 시청 동작 추가
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChapterListPage(
                            lectureID: widget.lectureID,
                            userInfo: widget.userInfo)),
                  );
                } else {
                  // 결제하기 버튼 동작 추가
                }
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(350, 50)),
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
              child: Text(
                data.lectureMaterialsActive.ispurchased == 1 ? '강의 시청' : '결제하기',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double scope) {
    return RatingBar.builder(
      initialRating: scope,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        // 별점이 업데이트될 때의 동작
      },
    );
  }

  Widget _buildButton(String label, String content,
      {required int isPurchased}) {
    return TextButton(
      onPressed: () {
        // 버튼 동작 추가
        if (isPurchased == 1) {
          // 결제된 경우 강의 자료 표시 또는 다른 동작 수행
          setState(() {
            selectedContent = content;
          });
        } else {
          // 결제되지 않은 경우 팝업 표시
          _showPaymentPopup(isPurchased);
        }
        // setState(() {
        //   selectedContent = content;
        // });
      },
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            // 버튼의 색상 결정
            // isPurchased 값에 따라 색상 변경
            return isPurchased == 1 ? Colors.greenAccent : Colors.grey;
          },
        ),
      ),
      child: Text(label),
    );
  }

  void _showPaymentPopup(int isPurchased) {
    if (isPurchased == 0) {
      // 결제되지 않은 경우 팝업 창 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('이용 불가'),
            content: Text('결제 이후에 이용이 가능합니다.'),
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
  }
}
