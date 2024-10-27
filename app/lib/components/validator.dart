// validator.dart
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return '이름을 입력하세요';
  } else if (value.length < 2) {
    return '이름은 두 글자 이상이어야 합니다';
  }
  return null;
}

String? validateEmail(String? value) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (value == null || value.isEmpty) {
    return '이메일을 입력하세요';
  } else if (!emailRegex.hasMatch(value)) {
    return '유효한 이메일을 입력하세요';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return '비밀번호를 입력하세요';
  } else if (value.length < 10) {
    return '비밀번호는 10자 이상이어야 합니다';
  }
  return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return '비밀번호 확인을 입력하세요';
  } else if (password != confirmPassword) {
    return '비밀번호가 일치하지 않습니다';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return '전화번호를 입력하세요';
  } else if (value.length < 10) {
    return '전화번호는 10자 이상이어야 합니다';
  }
  return null;
}
