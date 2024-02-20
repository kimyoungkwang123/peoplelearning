import 'package:flutter/material.dart';
import 'package:flutter_app/mainpage/baket-delete-api.dart';
import 'basket-api.dart';
import '../payment.dart';
import 'baket-delete-api.dart';

class BasketPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  BasketPage({required this.userInfo});

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<Lecture> courses = [];
  bool allSelected = false;
  late List<bool> selectedCourses;

  @override
  void initState() {
    super.initState();
    // initState에서 초기화를 수행합니다.
    selectedCourses = [];
    _fetchBasketData(); // 수강 바구니 데이터 가져오기
  }

  // 서버에서 수강 바구니 데이터를 가져오는 함수
  void _fetchBasketData() async {
    final userEmail = widget.userInfo?['userEmail']; // 사용자 이메일
    final result = await fetchBasket(userEmail);

    if (result['success']) {
      setState(() {
        // 성공적으로 데이터를 가져왔을 때
        courses = List<Lecture>.from(
          result['data']['mybasket_list']
              .map((course) => Lecture.fromJson(course)),
        );
        selectedCourses = List.generate(courses.length, (index) => false);
      });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수강 바구니'),
      ),
      body: Column(
        children: [
          _buildSelectAllCheckbox(),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return _buildCourseItem(index);
              },
            ),
          ),
          _buildTotalPaymentButton(), // 총합 가격과 결제하기 버튼 추가
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          child: Checkbox(
            value: allSelected,
            onChanged: (value) {
              setState(() {
                allSelected = value!;
                for (int i = 0; i < selectedCourses.length; i++) {
                  selectedCourses[i] = value!;
                }
              });
            },
          ),
        ),
        Text(
          '전체 선택',
          style: TextStyle(fontSize: 25.0),
        ),
      ],
    );
  }

  Widget _buildCourseItem(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // 테두리 색상 지정
        borderRadius: BorderRadius.all(Radius.circular(8.0)), // 테두리 모서리 둥글기 설정
      ),
      margin: EdgeInsets.all(8.0), // Container에 마진 추가

      child: ListTile(
        contentPadding: EdgeInsets.all(8.0),
        title: Row(
          children: [
            Checkbox(
              value: selectedCourses[index],
              onChanged: (value) {
                setState(() {
                  selectedCourses[index] = value!;
                  allSelected = selectedCourses.every((element) => element);
                });
              },
            ),
            SizedBox(width: 8.0), // 체크박스와 이미지 간격 조절
            Image.asset(
              'assets/image/${courses[index].Lecture_image_URL}', // 강의 이미지 URL
              width: 75.0,
              height: 110.0,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 8.0), // 이미지와 강의 제목 간격 조절
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courses[index].lectureTitle,
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 8.0), // 강의 제목과 강사 이름 간격 조절
                  Text('${courses[index].instructorName}'),
                  SizedBox(height: 8.0), // 강사 이름과 가격 간격 조절
                  Text(
                    '가격: ${courses[index].price}원',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('확인'),
                      content: Text('장바구니에서 이 항목을 삭제하시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final userEmail = widget.userInfo?['userEmail'];
                            // 서버에 장바구니 삭제 요청 보내기
                            final result = await deleteFromBasket(
                                userEmail, courses[index].shopping_basketID);

                            if (result['success']) {
                              // 성공적으로 삭제되었을 때
                              setState(() {
                                courses.removeAt(index);
                                selectedCourses.removeAt(index);
                                allSelected =
                                    selectedCourses.every((element) => element);
                              });
                            } else {
                              // 삭제 실패 시
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('에러'),
                                    content: Text(result['error']),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          '확인',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(
                            '예',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '아니오',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPaymentButton() {
    int totalAmount = 0;
    for (int i = 0; i < selectedCourses.length; i++) {
      if (selectedCourses[i]) {
        totalAmount += courses[i].price;
      }
    }

    return Container(
      margin: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총합 가격: $totalAmount 원',
            style: TextStyle(fontSize: 25),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 결제 버튼을 눌렀을 때의 동작
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage()),
              );
            },
            child: Text(
              '결제하기',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
