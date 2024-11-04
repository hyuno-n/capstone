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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

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

  bool _validateFields() {
    if (_selectedTabIndex == 1 && _usernameController.text.isEmpty) {
      showWarningDialog(context, '아이디를 입력하세요.');
      return false;
    }
    if (_nameController.text.isEmpty) {
      showWarningDialog(context, '이름을 입력하세요.');
      return false;
    }
    if (_emailOrPhoneController.text.isEmpty) {
      showWarningDialog(
          context, _isEmailSelected ? '이메일을 입력하세요.' : '휴대폰 번호를 입력하세요.');
      return false;
    }
    if (_selectedTabIndex == 1 && _newPasswordController.text.isEmpty) {
      showWarningDialog(context, '새 비밀번호를 입력하세요.');
      return false;
    }
    return true;
  }

  void _handleSubmit() {
    if (_validateFields()) {
      if (_selectedTabIndex == 0) {
        // 아이디 찾기
        _controller.findUserId(
          context,
          _nameController.text,
          _emailOrPhoneController.text,
        );
      } else {
        // 비밀번호 찾기 (사용자 인증 후 비밀번호 변경)
        _controller
            .verifyUserForPasswordReset(
          context,
          _usernameController.text,
          _emailOrPhoneController.text,
        )
            .then((_) {
          if (_newPasswordController.text.isNotEmpty) {
            _controller.updatePassword(
              context,
              _usernameController.text,
              _newPasswordController.text,
            );
          }
        });
      }
    } else {
      _shakeForm();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailOrPhoneController.dispose();
    _usernameController.dispose();
    _newPasswordController.dispose();
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
            Text(
              '아이디 • 비밀번호 찾기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('아이디 찾기', 0),
                _buildTabButton('비밀번호 찾기', 1),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _isEmailSelected = true;
        });
      },
      child: Column(
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
      ),
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
              buildTextField(_usernameController, '아이디를 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_nameController, '이름을 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_emailOrPhoneController,
                  _isEmailSelected ? '이메일을 입력하세요' : '휴대폰 번호를 입력하세요'),
              const SizedBox(height: 10),
              buildTextField(_newPasswordController, '새 비밀번호를 입력하세요'),
              const SizedBox(height: 20),
              _buildSubmitButton('비밀번호 찾기'),
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
}
