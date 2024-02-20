import 'package:flutter/material.dart';
import 'package:flutter_app/main-page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: 'dbce2611e47a9f5a44dfdf3648cd0502',
    javaScriptAppKey: '78888d7f9464d74b51a9149b679adee3',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: MainPage(),
    );
  }
}
