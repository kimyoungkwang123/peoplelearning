import 'package:flutter/material.dart';
import 'ChapterListPage-api.dart';
import 'video-page.dart';

class ChapterListPage extends StatefulWidget {
  final int lectureID;
  final Map<String, dynamic>? userInfo;

  ChapterListPage({required this.lectureID, this.userInfo});

  @override
  _ChapterListPageState createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  List<LectureContent> chapterList = [];

  @override
  void initState() {
    super.initState();
    _fetchChapterList();
  }

  Future<void> _fetchChapterList() async {
    try {
      final List<LectureContent> result =
          await ChapterListPageApi.fetchChapterList(widget.lectureID);
      setState(() {
        chapterList = result;
      });
    } catch (error) {
      print('Error fetching chapter list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강의 목록'),
      ),
      body: ListView.builder(
        itemCount: chapterList.length,
        itemBuilder: (context, index) {
          final chapter = chapterList[index];
          return _buildChapterTile(
            context,
            chapter.contentTitle,
            chapter.subChapters,
          );
        },
      ),
    );
  }

  Widget _buildChapterTile(
      BuildContext context, String chapterTitle, List<SubChapter> subChapters) {
    // 총 동영상 시간 계산
    int totalMinutes = 0;
    for (SubChapter chapter in subChapters) {
      totalMinutes += chapter.video_time;
    }

    // 수정된 부분: totalDuration 계산
    String totalDuration = _convertMinutesToTimeString(totalMinutes);

    return ListTile(
      title: Text(chapterTitle),
      subtitle: Text('동영상 시간: $totalDuration'),
      onTap: () {
        _showSubChapters(context, chapterTitle, subChapters);
      },
    );
  }

  void _showSubChapters(
      BuildContext context, String contentTitle, List<SubChapter> subChapters) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$contentTitle'),
          content: Column(
            children: [
              for (SubChapter chapter in subChapters)
                ListTile(
                  title: Text(chapter.table_of_contents_of_sub_lecturesTitle),
                  subtitle: Text(
                      '동영상 시간: ${_convertMinutesToTimeString(chapter.video_time)}'), // 수정된 부분
                  onTap: () {
                    Navigator.pop(context, contentTitle);
                    _handleSubChapterTap(context, contentTitle, chapter);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubChapterTap(
      BuildContext context, String parentChapter, SubChapter subChapter) {
    // 동영상 페이지로 이동하는 코드
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPage(
            lectureID: widget.lectureID,
            table_of_contents_of_sub_lecturesID:
                subChapter.table_of_contents_of_sub_lecturesID,
            userInfo: widget.userInfo),
      ),
    );
  }

  String _convertMinutesToTimeString(int minutes) {
    int hours = minutes ~/ 3600; // 시간 계산
    int remainingMinutes = (minutes ~/ 60) % 60; // 분 계산
    int remainingSeconds = minutes % 60; // 초 계산

    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
