import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/components/common_widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPasswordController {
  final String? flaskIp = dotenv.env['FLASK_IP'];
  final String? flaskPort = dotenv.env['FLASK_PORT'];

  String getBaseUrl() {
    return 'http://$flaskIp:$flaskPort';
  }

  /// 아이디 찾기 기능 (이메일 또는 휴대폰 인증)
  Future<void> findUserId(
      BuildContext context, String name, String contact) async {
    final String url = '${getBaseUrl()}/find_user_id';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'contact': contact}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['user_id'];
        showWarningDialog(context, '아이디 찾기 성공: 아이디는 $userId 입니다.');
      } else {
        final error = jsonDecode(response.body)['error'];
        showWarningDialog(context, error ?? '아이디 찾기 실패');
      }
    } catch (e) {
      showWarningDialog(context, '아이디 찾기 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 찾기 기능 - 사용자 인증 (아이디와 이메일/휴대폰 인증)
  Future<void> verifyUserForPasswordReset(
      BuildContext context, String userId, String contact) async {
    final String url = '${getBaseUrl()}/verify_user_for_password_reset';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId, 'contact': contact}),
      );

      if (response.statusCode == 200) {
        showWarningDialog(context, '사용자 인증이 완료되었습니다. 비밀번호를 재설정하세요.');
      } else {
        final error = jsonDecode(response.body)['error'];
        showWarningDialog(context, error ?? '사용자 인증 실패');
      }
    } catch (e) {
      showWarningDialog(context, '비밀번호 찾기 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 업데이트 기능
  Future<void> updatePassword(
      BuildContext context, String userId, String newPassword) async {
    final String url = '${getBaseUrl()}/update_password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId, 'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        showWarningDialog(context, '비밀번호가 성공적으로 변경되었습니다.');
      } else {
        final error = jsonDecode(response.body)['error'];
        showWarningDialog(context, error ?? '비밀번호 변경 실패');
      }
    } catch (e) {
      showWarningDialog(context, '비밀번호 변경 중 오류가 발생했습니다.');
    }
  }
}
