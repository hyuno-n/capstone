import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app/controller/forgot_password_controller.dart';
import 'package:app/components/common_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final ForgotPasswordController _controller = ForgotPasswordController();

  int _selectedTabIndex = 0; // 0: 아이디 찾기, 1: 비밀번호 찾기
  bool _isEmailSelected = true; // 이메일 인증과 휴대폰 인증 구분
  bool _isVerified = false; // 인증 완료 여부
  bool _isPasswordVerified = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.05, 0))
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
  }

  void _shakeForm() {
    _animationController.forward(from: 0);
  }

  void _resetFields() {
    _nameController.clear();
    _idController.clear();
    _emailOrPhoneController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _isEmailSelected = true; // 인증 방법 초기화
  }

  bool _validateFields() {
    if (_selectedTabIndex == 0) {
      // 아이디 찾기 탭에서의 입력 검증
      if (_nameController.text.isEmpty) {
        showWarningDialog(context, '이름을 입력하세요.', '입력 오류');
        return false;
      }
      if (_emailOrPhoneController.text.isEmpty) {
        showWarningDialog(context,
            _isEmailSelected ? '이메일을 입력하세요.' : '휴대폰 번호를 입력하세요.', '입력 오류');
        return false;
      }
    } else if (_selectedTabIndex == 1) {
      // 비밀번호 찾기 탭에서의 입력 검증
      if (!_isVerified) {
        if (_nameController.text.isEmpty) {
          showWarningDialog(context, '이름을 입력하세요.', '입력 오류');
          return false;
        }
        if (_idController.text.isEmpty) {
          showWarningDialog(context, '아이디를 입력하세요.', '입력 오류');
          return false;
        }
        if (_emailOrPhoneController.text.isEmpty) {
          showWarningDialog(context,
              _isEmailSelected ? '이메일을 입력하세요.' : '휴대폰 번호를 입력하세요.', '입력 오류');
          return false;
        }
      } else {
        // 인증 후 비밀번호 변경 필드 검증
        if (_newPasswordController.text.isEmpty) {
          showWarningDialog(context, '새 비밀번호를 입력하세요.', '입력 오류');
          return false;
        }
        if (_confirmPasswordController.text.isEmpty) {
          showWarningDialog(context, '비밀번호 확인을 입력하세요.', '입력 오류');
          return false;
        }
        if (_newPasswordController.text != _confirmPasswordController.text) {
          showWarningDialog(context, '비밀번호가 일치하지 않습니다.', '입력 오류');
          return false;
        }
      }
    }
    return true;
  }

  void _handleSubmit() {
    if (_validateFields()) {
      final contact = _emailOrPhoneController.text.trim();

      if (_selectedTabIndex == 0) {
        // 아이디 찾기 탭
        _controller
            .findUserId(
              context,
              _nameController.text.trim(),
              contact,
            )
            .then((_) {})
            .catchError((error) {
          showWarningDialog(context, '오류', '아이디 찾기 중 오류가 발생했습니다.');
        });
      } else if (_selectedTabIndex == 1) {
        // 비밀번호 찾기 탭
        if (!_isVerified) {
          _controller
              .verifyUserForPasswordReset(
            context,
            _idController.text.trim(),
            contact,
          )
              .then((isVerified) {
            if (isVerified) {
              setState(() {
                _isVerified = true;
              });
              _showVerificationSuccessDialog(); // 인증 완료 다이얼로그 호출
            } else {
              showWarningDialog(context, '오류', '아이디나 인증 정보가 일치하지 않습니다.');
            }
          });
        } else {
          _showPasswordChangeDialog(); // 이미 인증된 경우 비밀번호 변경 다이얼로그 호출
        }
      }
    } else {
      _shakeForm();
    }
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedTabIndex = index;
      _isEmailSelected = true;
      // 탭 변경 시 인증 상태 초기화
      if (index == 0) {
        _isVerified = false;
      } else if (index == 1) {
        _isPasswordVerified = false;
      }
      _resetFields();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailOrPhoneController.dispose();
    _idController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/MVCCTV_main.png',
              height: 180,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _handleTabChange(0),
                  child: _buildTabButton('아이디 찾기', 0),
                ),
                GestureDetector(
                  onTap: () => _handleTabChange(1),
                  child: _buildTabButton('비밀번호 변경', 1),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _selectedTabIndex == 0
                ? _buildIdFindOptions()
                : _buildPasswordFindOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: _selectedTabIndex == index ? Colors.black : Colors.grey,
          ),
        ),
        if (_selectedTabIndex == index)
          Container(
            height: 2,
            width: 100,
            color: Colors.black,
            margin: EdgeInsets.only(top: 4),
          ),
      ],
    );
  }

  Widget _buildIdFindOptions() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _shakeAnimation.value,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton('이메일 인증', true),
                  const SizedBox(width: 10),
                  _buildOptionButton('휴대폰 인증', false),
                ],
              ),
              const SizedBox(height: 20),
              buildTextField(_nameController, '이름을 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_emailOrPhoneController,
                  _isEmailSelected ? '이메일을 입력하세요' : '휴대폰 번호를 입력하세요'),
              const SizedBox(height: 20),
              _buildSubmitButton('아이디 찾기'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordFindOptions() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _shakeAnimation.value,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton('이메일 인증', true),
                  const SizedBox(width: 10),
                  _buildOptionButton('휴대폰 인증', false),
                ],
              ),
              const SizedBox(height: 20),
              buildTextField(_nameController, '이름을 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_idController, '아이디를 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_emailOrPhoneController,
                  _isEmailSelected ? '이메일을 입력하세요' : '휴대폰 번호를 입력하세요'),
              const SizedBox(height: 20),
              _buildSubmitButton('비밀번호 변경'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(String text, bool isEmailOption) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEmailSelected = isEmailOption;
          _nameController.clear();
          _idController.clear();
          _emailOrPhoneController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _isEmailSelected == isEmailOption
              ? Colors.black
              : Colors.grey[300],
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                _isEmailSelected == isEmailOption ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String buttonText) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showVerificationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            '인증 완료',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            '사용자 인증이 완료되었습니다. 비밀번호를 재설정하세요.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _showPasswordChangeDialog(); // 비밀번호 변경 다이얼로그 호출
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            '비밀번호 변경',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  _controller.updatePassword(
                    context,
                    _idController.text.trim(),
                    _newPasswordController.text.trim(),
                  );
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                } else {
                  showWarningDialog(context, '비밀번호가 일치하지 않습니다.', '입력 오류');
                }
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.black,
              ),
              child: const Text(
                '변경',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isVerified = false;
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.grey[300],
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
