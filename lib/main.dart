import 'package:flutter/material.dart';
import 'package:sign_image/sign_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: MarkImage(
            imageNam: 'assets/image.png',
          ),
        ),
      ),
    );
  }
}