import 'package:flutter/material.dart';
import 'package:flutter_app/main-page.dart';
import 'package:http/http.dart' as http;
import '../detail-lecture.dart';
import 'dart:convert';

class PopularLectures extends StatefulWidget {
  @override
  _PopularLecturesState createState() => _PopularLecturesState();
}

class _PopularLecturesState extends State<PopularLectures> {
  List<Lecture> popularLectures = [];

  @override
  void initState() {
    super.initState();
    fetchPopularLectures();
  }

  Future<void> fetchPopularLectures() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.75:3010/mainpage/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['code'] == 200) {
        final List<dynamic> lectureList = data['lecture_list'];

        setState(() {
          popularLectures =
              lectureList.map((item) => Lecture.fromJson(item)).toList();
        });
      } else {
        throw Exception(
            'Failed to load data. Server responded with code ${data['code']}');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    popularLectures.sort((a, b) => b.average_scope.compareTo(a.average_scope));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: popularLectures.map((lecture) {
          return buildItem(context, lecture);
        }).toList(),
      ),
    );
  }

  Widget buildItem(BuildContext context, Lecture lecture) {
    return GestureDetector(
      onTap: () async {
        final detailResponse = await http
            .get(Uri.parse('http://192.168.0.75:3010/lecturedetail/'));

        if (detailResponse.statusCode == 200) {
          final Map<String, dynamic> detailData =
              json.decode(detailResponse.body);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLecturePage(
                lectureID: detailData['lectureID'],
                categoryId: detailData['categoryID'],
              ),
            ),
          );
        } else {
          throw Exception('Failed to load detail data');
        }
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: 200.0, // 강의 아이템의 너비 조절
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/image/${lecture.imageURL}',
              width: double.infinity,
              height: 120.0,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8.0),
            Text(
              lecture.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            StarRating(rating: lecture.average_scope), // 별점 추가
            Text('강사: ${lecture.instructorName}'),
            Text('가격: ${lecture.price} 원'),
          ],
        ),
      ),
    );
  }
}

class Lecture {
  final int lectureID;
  final String title;
  final String instructorName;
  final String imageURL;
  final int price;
  final double average_scope;
  final String categoryName;
  final int categoryID;

  Lecture(
      {required this.lectureID,
      required this.title,
      required this.instructorName,
      required this.imageURL,
      required this.price,
      required this.average_scope,
      required this.categoryName,
      required this.categoryID});

  // JSON 데이터를 Lecture 객체로 변환하는 정적 메서드
  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      lectureID: json['lectureID'] ?? 0, // 기본값으로 0을 사용하거나, 적절한 기본값을 선택
      imageURL: json['Lecture_image_URL'] ?? '',
      price: json['price'] ?? 0, // 기본값으로 0을 사용하거나, 적절한 기본값을 선택
      title: json['lectureTitle'] ?? '',
      average_scope: (json['average_scope'] as num?)?.toDouble() ?? 0.0,
      instructorName: json['instructorName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryID: json['categoryID'] ?? '',
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;

  StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double starPosition = (index + 1) * 1.0;
        return Icon(
          starPosition <= rating
              ? Icons.star
              : (starPosition - 0.5 <= rating
                  ? Icons.star_half
                  : Icons.star_border),
          color: Colors.amber,
        );
      }),
    );
  }
}
