import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'loading.dart';
import 'main.dart';

class AddAttraction extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String title;

  void add_attraction(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    final result = await http.post(
        Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/add_attraction"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title' : title
        }));

      Navigator.push(context, MaterialPageRoute(builder: (context) => LoadImage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff44004a),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.add_business),
              hintText: 'Введите название памятника',
              hintStyle: TextStyle(fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
              fillColor: Color(0xff75007f)
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Введите название памятника';
              }
              title = value;
            },
          ),
          const SizedBox(height: 50),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState!.validate()) {
                    add_attraction(context);
                  }
                },
                child: const Text('Подтвердить смену пароля'),
              )
          )
        ]
      )
    );
  }
}

