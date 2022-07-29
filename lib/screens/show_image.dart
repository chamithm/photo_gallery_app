import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  String url;
  ShowImage(this.url);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Container(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          )
        )
      ),
    );
  }
}