// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class VideoWidget extends StatefulWidget {
//   final String videoUrl;

//   VideoWidget({required this.videoUrl});

//   @override
//   _VideoWidgetState createState() => _VideoWidgetState();
// }

// class _VideoWidgetState extends State<VideoWidget> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();

//     // YoutubePlayerController를 생성하고 초기화합니다.
//     _controller = YoutubePlayerController(
//       initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl) ??
//           '', // null일 경우 빈 문자열로 대체
//       flags: YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(20),
//       width: double.infinity,
//       height: 220.0, // 고정값으로 변경
//       child: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//         progressIndicatorColor: Colors.blueAccent,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // YoutubePlayerController의 dispose 메소드를 호출하여 메모리 누수를 방지합니다.
//     _controller.dispose();
//     super.dispose();
//   }

//   // void _selectLecture(String videoUrl) {
//   //   // YoutubePlayerController를 다시 초기화하여 동영상을 껐다가 다시 만듭니다.
//   //   _controller = YoutubePlayerController(
//   //     initialVideoId: YoutubePlayer.convertUrlToId(videoUrl) ?? '',
//   //     flags: YoutubePlayerFlags(
//   //       autoPlay: true,
//   //       mute: false,
//   //     ),
//   //   );

//   //   setState(() {
//   //     currentVideoUrl = videoUrl;
//   //   });

//   //   // 팝업 닫기
//   //   Navigator.of(context).pop();
//   // }
// }
