import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:touristic_helper/auth.dart';
import 'package:touristic_helper/loading.dart';
import 'package:touristic_helper/main.dart';
import 'package:mysql1/mysql1.dart';

import 'package:http/http.dart' as http;
import 'package:touristic_helper/registration.dart';

String email = "";

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String password = "";

  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void is_email_exist(String email) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    final result = await http.post(
        Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/email_exist"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }));
    if (result.body != "True") {
      print(result.body);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Registration()));
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitPassword()));
    }
  }

  void send_code(String email) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    final result = await http.post(
        Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/send_code"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff44004a),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Введите вашу почту',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(),
                  fillColor: Color(0xff75007f)
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty ||
                    value.contains("@") == false || value.length < 4) {
                  return 'Введите вашу реальную почту';
                }
                email = value;
              },
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      is_email_exist(email);
                      send_code(email);
                    }
                  },
                  child: const Text('Выслать код'),
                )
            )
          ],
        ),
      ),
    );
  }
}

class SubmitPassword extends StatefulWidget {
  const SubmitPassword({Key? key}) : super(key: key);

  @override
  _SubmitPasswordState createState() => _SubmitPasswordState();
}

class _SubmitPasswordState extends State<SubmitPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String password = "", confirm_code = "";

  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void change_password(String email, String code, String password) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    final result = await http.post(
        Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/change_password"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'code' : code
        }));
    if (result.body != "True") {
      print(result.body);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Registration()));
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Auth()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff44004a),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              obscureText: !_showPassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Введите код подтверждения',
                hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
                fillColor: Color(0xff75007f),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Введите код подтверждения с почты';
                }
                confirm_code = value;
              },
            ),
            const SizedBox(height: 25),
            TextFormField(
              obscureText: !_showPassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Введите новый пароль',
                hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
                fillColor: Color(0xff75007f),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _togglevisibility();
                  },
                  child: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xff75007f),
                  ),
                ),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Введите ваш реальный пароль';
                }
                if (value.length < 6) {
                  return 'Ваш пароль слишком короткий';
                }
                password = value;
              },
            ),
            const SizedBox(height: 25),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      change_password(email, confirm_code, password);
                    }
                  },
                  child: const Text('Подтвердить смену пароля'),
                )
            )
          ],
        ),
      ),
    );
  }
}

