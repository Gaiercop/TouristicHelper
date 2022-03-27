import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:touristic_helper/auth.dart';
import 'package:touristic_helper/loading.dart';
import 'package:touristic_helper/main.dart';
import 'package:mysql1/mysql1.dart';

import 'package:http/http.dart' as http;

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "", password = "";

  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
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
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SubmitPassword()));
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

  String email = "", password = "";

  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
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
                // TODO: добавить проверку кода подтверждения
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Auth()));
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

