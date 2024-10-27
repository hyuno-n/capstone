import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_protect/components/validator.dart';
import 'package:home_protect/pages/login_page.dart';
import 'package:kpostal/kpostal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _baseAddressController.dispose();
    _detailedAddressController.dispose();
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

  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final String id = _nameController.text;
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String phone = _phoneController.text;
      final String address = _addressController.text;
      final String detailedAddress = _detailedAddressController.text;

      final String? flaskAppIp = dotenv.env['FLASK_IP'];
      final String? flaskAppPort = dotenv.env['FLASK_PORT'];
      final String url = 'http://$flaskAppIp:$flaskAppPort/add_user';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'email': email,
            'password': password, // 비밀번호 필드 추가
            'phone': phone,
            'address': address,
            'detailed_address': detailedAddress,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'User added successfully: ${responseData['message']}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login_Page()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed tao add user: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CupertinoPageScaffold를 Scaffold로 변경
      appBar: AppBar(
        title: const Text("Sign up"),
      ),
      body: SafeArea(
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
                      "아이디",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: "Enter your id",
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
                              builder: (context) {
                                return KpostalView(callback: (Kpostal result) {
                                  setState(() {
                                    _addressController.text = result.postCode;
                                    _baseAddressController.text =
                                        result.address;
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
                              _nameController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              _confirmPasswordController.text.isNotEmpty &&
                              _phoneController.text.isNotEmpty &&
                              _addressController.text.isNotEmpty &&
                              _baseAddressController.text.isNotEmpty &&
                              _detailedAddressController.text.isNotEmpty) {
                            _registerUser(context);
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
