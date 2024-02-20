import 'package:flutter/material.dart';
import 'package:flutter_app/ChapterListPage.dart';
import 'mylecutre-api.dart';

class MyLecturePage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  MyLecturePage({this.userInfo});

  @override
  _MyLecturePageState createState() => _MyLecturePageState();
}

class _MyLecturePageState extends State<MyLecturePage> {
  String _currentSortBy = '이름순';
  String _selectedCategory = '전체';
  late Future<List<Lecture>> _lectureFuture; // 변경: Future 선언

  @override
  void initState() {
    super.initState();
    _lectureFuture = _loadLectures('전체', '이름순'); // 변경: 초기 데이터 로드
  }

  Future<List<Lecture>> _loadLectures(String type, String sort) async {
    if (widget.userInfo == null || widget.userInfo!['userEmail'] == null) {
      return Future.error('User info or email not available');
    }

    String userEmail = widget.userInfo!['userEmail'];
    try {
      List<Lecture> lectures =
          await MyLectureApi.fetchUserLectures(userEmail, type, sort);
      return lectures;
    } catch (error) {
      print(error);
      throw Exception(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 강의'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton('전체', '전체', _currentSortBy),
                _ActionButton('학습중', '학습중', _currentSortBy),
                _ActionButton('완강', '완강', _currentSortBy),
                _lectureDropdownButton()
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Lecture>>(
              future: _lectureFuture, // 변경: FutureBuilder에 Future 전달
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  List<Lecture> lectures = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1 / 0.7,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: lectures.length,
                    itemBuilder: (context, index) {
                      return _buildLectureItem(context, lectures[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ActionButton(String label, String type, String sort) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = label;
          });
          _lectureFuture =
              _loadLectures(type, sort); // 변경: 드롭다운 선택 시 Future 업데이트
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(15, 40),
          primary: _selectedCategory == label
              ? Colors.greenAccent
              : Color.fromARGB(255, 179, 174, 174),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  Widget _lectureDropdownButton() {
    return DropdownButton<String>(
      value: _currentSortBy,
      items: ['이름순', '진행률 높은순', '진행률 낮은순'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _currentSortBy = newValue!;
          _lectureFuture = _loadLectures(
              _selectedCategory, _currentSortBy); // 변경: 드롭다운 선택 시 Future 업데이트
        });
      },
    );
  }

  Widget _buildLectureItem(BuildContext context, Lecture lecture) {
    return InkWell(
      onTap: () {
        // TODO: 강의 상세 페이지로 이동
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/image/${lecture.Lecture_image_URL}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.lectureTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 7),
                  Container(
                    height: 20, // 진행률 바의 높이를 20으로 설정
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10), // 모서리를 둥글게 만듭니다. 반지름 값은 진행률 바의 높이의 절반이 적당할 수 있습니다.
                      child: LinearProgressIndicator(
                        value: lecture.progress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '진행률: ${(lecture.progress).toStringAsFixed(2)}%', // 진행률을 백분율 형태로 표시
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChapterListPage(
                                    lectureID: lecture.lectureID,
                                    userInfo: widget.userInfo)),
                          );
                        },
                        child: Text('강의 시청'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
