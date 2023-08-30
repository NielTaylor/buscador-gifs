// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PaginaGif extends StatelessWidget {
  const PaginaGif({super.key, required this.dadosGif});

  final Map? dadosGif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dadosGif?['title']),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image.network(dadosGif?['images']['original']['url']),
        ),
      )
    );
  }
}