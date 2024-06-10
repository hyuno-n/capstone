import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // flutter_localizations 추가
import 'package:home_protect/components/validator.dart';
import 'package:home_protect/pages/login_page.dart';
import 'package:kpostal/kpostal.dart';

class Sign_up_Page extends StatelessWidget {
  const Sign_up_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('ko', ''), // Korean, no country code
        // 다른 필요한 로케일 추가
      ],
      home: SignUpPageContent(),
    );
  }
}

class SignUpPageContent extends StatefulWidget {
  const SignUpPageContent({super.key});

  @override
  State<SignUpPageContent> createState() => _SignUpPageContentState();
}

class _SignUpPageContentState extends State<SignUpPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _baseAddressController = TextEditingController(); // 기본주소
  final _detailedAddressController = TextEditingController(); // 상세주소

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose(); // 이름 dispose
    _emailController.dispose(); // 이메일 dispose
    _passwordController.dispose(); // 비밀번호 dispose
    _confirmPasswordController.dispose(); // 비밀번호 확인 dispose
    _phoneController.dispose(); // 전화번호 dispose
    _addressController.dispose(); // 주소 dispose
    _baseAddressController.dispose(); // 기본주소 dispose
    _detailedAddressController.dispose(); // 상세주소 dispose
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _nameError = validateName(_nameController.text);
      _emailError = validateEmail(_emailController.text);
      _passwordError = validatePassword(_passwordController.text);
      _confirmPasswordError = validateConfirmPassword(
          _passwordController.text, _confirmPasswordController.text);
      _phoneError = validatePhoneNumber(_phoneController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Sign up"),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "이름",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: "Enter your name",
                      onChanged: (value) {
                        setState(() {
                          _nameError = validateName(value);
                        });
                      },
                    ),
                    if (_nameError != null)
                      Text(
                        _nameError!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "이메일",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _emailController,
                      placeholder: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _emailError = validateEmail(value);
                        });
                      },
                    ),
                    if (_emailError != null)
                      Text(
                        _emailError!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "비밀번호",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _passwordController,
                      placeholder: "Enter your password",
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _passwordError = validatePassword(value);
                        });
                      },
                    ),
                    if (_passwordError != null)
                      Text(
                        _passwordError!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "비밀번호 확인",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _confirmPasswordController,
                      placeholder: "Confirm your password",
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordError = validateConfirmPassword(
                              _passwordController.text, value);
                        });
                      },
                    ),
                    if (_confirmPasswordError != null)
                      Text(
                        _confirmPasswordError!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "전화번호",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _phoneController,
                      placeholder: "Enter your phone number",
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _phoneError = validatePhoneNumber(value);
                        });
                      },
                    ),
                    if (_phoneError != null)
                      Text(
                        _phoneError!,
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "주소",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _addressController,
                            readOnly: true,
                            placeholder: "Enter your address",
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoButton.filled(
                          child: const Text("우편번호 찾기"),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                              //Kpostal 주소찾기 API 활용
                              builder: (context) {
                                return KpostalView(callback: (Kpostal result) {
                                  setState(() {
                                    _addressController.text =
                                        result.postCode; //주소에 번지수 들어감
                                    _baseAddressController.text =
                                        result.address; //기본주소에 주소명 들어감
                                  });
                                });
                              },
                            ));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "기본주소",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _baseAddressController,
                      readOnly: true,
                      placeholder: "Enter your base address",
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "상세주소",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _detailedAddressController,
                      placeholder: "Enter your detailed address",
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CupertinoButton.filled(
                        child: const Text("Sign Up"),
                        onPressed: () {
                          _validateInputs();
                          if (_formKey.currentState!.validate() &&
                              _nameController.text
                                  .isNotEmpty && // 회원가입 Field가 비워져있는지 아닌지 판별
                              _emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              _confirmPasswordController.text.isNotEmpty &&
                              _phoneController.text.isNotEmpty &&
                              _addressController.text.isNotEmpty &&
                              _baseAddressController.text.isNotEmpty &&
                              _detailedAddressController.text.isNotEmpty) {
                            // Handle sign up action
                            print("Name: ${_nameController.text}, "
                                "Email: ${_emailController.text}, "
                                "Password: ${_passwordController.text}, "
                                "Confirm Password: ${_confirmPasswordController.text}, "
                                "Phone: ${_phoneController.text}, "
                                "Address: ${_addressController.text}, "
                                "Base Address: ${_baseAddressController.text}, "
                                "Detailed Address: ${_detailedAddressController.text}");
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text('회원가입 완료'),
                                  content: const Text('회원가입이 완료되었습니다.'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Login_Page()),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text('회원가입 실패'),
                                  content: const Text('회원가입에 모든 칸을 입력해주세요.'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
