import 'package:flutter/material.dart';
import 'package:flutter_app/mainpage/searchAPI.dart';
import '../../detail-lecture.dart';
import '../searchAPI.dart';

class SearchLecturePage extends StatefulWidget {
  final int categoryID; // 클래스 타입 변경
  final String lectureTitle;
  final Map<String, dynamic>? userInfo;

  SearchLecturePage(
      {required this.categoryID,
      required this.lectureTitle,
      required this.userInfo});

  @override
  _SearchLecturePageState createState() => _SearchLecturePageState();
}

class _SearchLecturePageState extends State<SearchLecturePage> {
  late Future<List<SearchLecture>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = SearchAPI.fetchSearchResults(
        widget.categoryID.toString(), widget.lectureTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색한 강의'),
      ),
      body: FutureBuilder<List<SearchLecture>>(
        future: _searchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return buildLectureItem(context, snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget buildLectureItem(BuildContext context, SearchLecture lecture) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLecturePage(
              lectureID: lecture.lectureID,
              categoryId: lecture.categoryID,
              userInfo: widget.userInfo,
            ),
          ),
        );
      },
      child: Container(
        child: Card(
          margin: EdgeInsets.all(10.0),
          elevation: 3.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/image/${lecture.Lecture_image_URL}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.lectureTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('강사: ${lecture.InstructorName}'),
                    Text('가격: ${lecture.price} 원'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
