import 'package:flutter/material.dart';
import 'package:flutter_app/detail-board.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'video-page-api.dart';
import 'video-board-page.dart';

class VideoPage extends StatefulWidget {
  final int lectureID;
  final int table_of_contents_of_sub_lecturesID;
  final Map<String, dynamic>? userInfo;

  VideoPage({
    required this.lectureID,
    required this.table_of_contents_of_sub_lecturesID,
    this.userInfo,
  });

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<Map<String, dynamic>> _videoDataFuture;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '', // 초기 값은 빈 문자열로 설정합니다.
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    _videoDataFuture = _fetchVideoData();
  }

  Future<Map<String, dynamic>> _fetchVideoData() async {
    try {
      return await VideoPageApi.fetchVideoData(
          widget.table_of_contents_of_sub_lecturesID.toString());
    } catch (error) {
      print('Error fetching video data: $error');
      throw Exception('Failed to load video data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder(
              future: _videoDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load video data'));
                } else {
                  final responseData = snapshot.data;
                  if (responseData != null &&
                      responseData.containsKey('data')) {
                    final dataList = responseData['data'] as List;
                    if (dataList.isNotEmpty) {
                      final videoData = dataList[0] as Map<String, dynamic>;
                      final String? chapterTitle =
                          videoData['table_of_contents_of_sub_lecturesTitle'];
                      final String? videoUrl = videoData['video_url'];
                      if (chapterTitle != null && videoUrl != null) {
                        _controller = YoutubePlayerController(
                          initialVideoId:
                              YoutubePlayer.convertUrlToId(videoUrl) ?? '',
                          flags: YoutubePlayerFlags(
                            autoPlay: true,
                            mute: false,
                          ),
                        );
                        return YoutubePlayer(
                          controller: _controller,
                          width: MediaQuery.of(context).size.width,
                          aspectRatio: 16 / 9,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.blueAccent,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.blue,
                            handleColor: Colors.blueAccent,
                          ),
                          onReady: () {
                            // 플레이어가 준비되면 호출되는 콜백
                          },
                          onEnded: (data) {
                            // 동영상 재생이 종료되면 호출되는 콜백
                          },
                        );
                      }
                    }
                  }
                  return Center(child: Text('No video data available'));
                }
              },
            ),
          ),
          Expanded(
            child: VideoBoardPage(userInfo: widget.userInfo),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
