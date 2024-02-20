import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/main-page.dart';
import 'update-user-api.dart';

class UpdateUserPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  UpdateUserPage({required this.userInfo});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이름 변경',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '새로운 이름 입력',
              ),
            ),
            SizedBox(height: 16.0),
            buildPasswordTextField(
              label: '현재 비밀번호',
              controller: _currentPasswordController,
              showPassword: _showCurrentPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _showCurrentPassword = !_showCurrentPassword;
                });
              },
            ),
            SizedBox(height: 16.0),
            buildPasswordTextField(
              label: '새로운 비밀번호',
              controller: _newPasswordController,
              showPassword: _showNewPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
            ),
            SizedBox(height: 16.0),
            buildPasswordTextField(
              label: '비밀번호 확인',
              controller: _confirmPasswordController,
              showPassword: _showConfirmPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 취소 버튼을 눌렀을 때의 동작 구현
                    Navigator.pop(context); // 현재 페이지를 닫음
                  },
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 변경 버튼을 눌렀을 때의 동작 구현
                    String newName = _nameController.text;
                    String currentPassword = _currentPasswordController.text;
                    String newPassword = _newPasswordController.text;
                    String confirmPassword = _confirmPasswordController.text;

                    // 사용자 정보
                    String userEmail = widget.userInfo?['userEmail'];
                    print(currentPassword);

                    // 새로운 비밀번호와 확인 비밀번호가 일치하는지 확인
                    if (newPassword != confirmPassword) {
                      print('confirmPassword: $confirmPassword');
                      // 새로운 비밀번호와 확인 비밀번호가 일치하지 않으면 에러 메시지 출력
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('새로운 비밀번호와 확인 비밀번호가 일치하지 않습니다.'),
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
                      return; // 새로운 비밀번호와 확인 비밀번호가 일치하지 않으면 더 이상 진행하지 않음
                    }

                    try {
                      // 변경 버튼을 누를 때 사용자 정보 업데이트 요청
                      await UpdateUserAPI.updateUser(
                          userEmail, newName, currentPassword, newPassword);

                      print('successfully');

                      // 성공 시 메인 페이지로 이동
                      Navigator.pop(context); // 현재 페이지 닫기
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainPage(), // MainPage는 실제 메인 페이지 위젯
                        ),
                      );
                    } catch (error) {
                      print(error);
                      // 업데이트 실패 시 에러 처리
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('서버와의 통신 중 오류가 발생했습니다.'),
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
                  },
                  child: Text('변경'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordTextField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback togglePasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: '비밀번호 입력',
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: togglePasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
//김영광