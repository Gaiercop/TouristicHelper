import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:touristic_helper/loading.dart';
import 'package:touristic_helper/main.dart';
import 'package:mysql1/mysql1.dart';

import 'package:http/http.dart' as http;

import 'auth.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "", password = "";

  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void new_user(String email, String password) async {
    final result = await http.post(
        Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/register"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password
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
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Введите вашу почту',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      fillColor: Color(0xff75007f)
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty || value.contains("@") == false || value.length < 4) {
                      return 'Введите вашу почту';
                    }
                    email = value;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: 'Введите ваш пароль',
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
                      return 'Введите ваш пароль';
                    }
                    if (value.length < 6) {
                      return 'Ваш пароль слишком короткий';
                    }
                    password = value;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: 'Введите ваш пароль повторно',
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
                      return 'Введите ваш пароль';
                    }
                    if (value.length < 6) {
                      return 'Ваш пароль слишком короткий';
                    }
                    if (value != password) {
                      return 'Введённые пароли не совпадают';
                    }
                    password = value;
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState!.validate()) {
                          new_user(email, password);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoadingScreen()));
                        }
                      },
                      child: const Text('Зарегистрироваться'),

                    )
                )
              ],
            )
        )
    );
    throw UnimplementedError();
  }
}
