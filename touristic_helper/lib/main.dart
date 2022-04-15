import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:animated_stack/animated_stack.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:touristic_helper/add_attraction.dart';
import 'package:touristic_helper/auth.dart';
import 'package:touristic_helper/loading.dart';

Future<Image> convertFileToImage(File picture) async {
  List<int> imageBase64 = picture.readAsBytesSync();
  String imageAsString = base64Encode(imageBase64);
  Uint8List uint8list = base64.decode(imageAsString);
  Image image = Image.memory(uint8list);
  return image;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Auth()
    );
  }
}

class LoadImage extends StatelessWidget {
  void takePhoto(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoadingScreen()));
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File imageFile = File(image.path);
      Image resultImage = await convertFileToImage(imageFile);

      var stream = new http.ByteStream(
          DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();

      var uri = Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/upload");

      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('file', stream, length,
          filename: basename(imageFile.path));
      //contentType: new MediaType('image', 'png'));

      request.files.add(multipartFile);
      var response = await request.send();
      String resultValue = "Cremlin";

      if (response.statusCode == 200) {
        resultValue = await response.stream.bytesToString();
        print(resultValue);
      }
      else{
        print("Error! Something went wrong");
      }

      sleep(const Duration(seconds: 1));
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ShowResult(resultImage, resultValue)));

    }
  }

  void selectPhoto(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoadingScreen()));
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      Image resultImage = await convertFileToImage(imageFile);

      var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();

      var uri = Uri.parse("http://ovz1.ss-di.m29on.vps.myjino.ru/api/upload");

      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('file', stream, length,
          filename: basename(imageFile.path));
      //contentType: new MediaType('image', 'png'));

      request.files.add(multipartFile);
      var response = await request.send();
      String resultValue = "Cremlin";

      if (response.statusCode == 200) {
        resultValue = await response.stream.bytesToString();
        print(resultValue);
      }
      else{
        print("Error! Something went wrong");
      }

      sleep(const Duration(seconds: 1));
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ShowResult(resultImage, resultValue)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AnimatedStack(
          backgroundColor: const Color(0xff75007f),

          fabBackgroundColor: Colors.deepPurple,

          foregroundWidget: Container(
            child: Scaffold(

              backgroundColor: Color(0xff44004a),
              body: Center(
                child: Text(
                  'Загрузите фото памятника, а мы его распознаем',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          bottomWidget: const Text(
            'Загрузите фото',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: Colors.white,
            ),
          ),

          columnWidget: Column(
            children: <Widget>[
              const SizedBox(height: 20),

              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.image),
                onPressed: () { selectPhoto(context); },
                backgroundColor: Colors.deepPurple,
              ),

              const SizedBox(height: 20),

              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.enhance_photo_translate),
                onPressed: () { takePhoto(context); },
                backgroundColor: Colors.deepPurple,
              ),
            ],
          ),
        )
    );
  }
}


class ShowResult extends StatefulWidget {
  late Image resultImage;
  late String resultString;

  ShowResult (Image image, String data) {
    resultImage = image;
    resultString = data;
  }
  @override
  ShowingResult createState()=> ShowingResult(this.resultImage, this.resultString);
}

class ShowingResult extends State<ShowResult>{
  late Image resultImage;
  late String resultString;

  ShowingResult (Image image, String data) {
    resultImage = image;
    resultString = data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff44004a),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            this.resultImage,
            Text(
              this.resultString,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontFamily: 'Montserrat',
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> LoadImage()));
                },
                child: const Text("Вернуться в главное меню")
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> AddAttraction()));
                },
                child: const Text("Добавить памятник")
            )
          ],
        )
    );
  }
}



