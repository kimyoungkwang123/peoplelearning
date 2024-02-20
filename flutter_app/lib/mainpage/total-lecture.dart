// total-lecture.dart

import 'package:flutter/material.dart';
import '../detail-lecture.dart';
import 'total-lecture-API.dart';

class TotalLecturePage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  TotalLecturePage({required this.userInfo});

  @override
  _TotalLecturePageState createState() => _TotalLecturePageState();
}

class _TotalLecturePageState extends State<TotalLecturePage> {
  String _selectedSortOption = '강의제목순';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전체 강의'),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: DropdownButton<String>(
              value: _selectedSortOption,
              items: ["강의제목순", "평균별점 높은순", "가격 높은순"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? selectedOption) {
                setState(() {
                  _selectedSortOption = selectedOption ?? '강의제목순';
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Lecture>>(
              future: TotalLectureApi.fetchLectures(
                _selectedSortOption.toLowerCase(),
                userInfo: widget.userInfo,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  List<Lecture> sortedLectures = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.4,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: sortedLectures.length,
                    itemBuilder: (context, index) {
                      return buildLectureItem(sortedLectures[index]);
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

  Widget buildLectureItem(Lecture lecture) {
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
                      'assets/image/${lecture.imageURL}',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    StarRating(rating: lecture.average_scope),
                    Text('강사: ${lecture.instructorName}'),
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
