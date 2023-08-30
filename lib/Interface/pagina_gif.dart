// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//1.1 importo/adicion o pacote share_plus que fornecerá a função de
//compartilhamento
import 'package:share_plus/share_plus.dart';

class PaginaGif extends StatelessWidget {
  const PaginaGif({super.key, required this.dadosGif});

  final Map? dadosGif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(dadosGif?['title']),
          backgroundColor: Colors.black,
          //1.2 defino uma ação na appBar
          actions: [
            //1.3 nessação ter um botão que mostra apenas um ícone (IconButton)
            IconButton(
              //1.4 ao pressionar o q irá acontecer é de fato o compartilhamento
              //usando a função/atributo de compartilhar do Share
              onPressed: () {
                Share.share(dadosGif?['images']['original']['url']);
              },
              icon: Icon(Icons.share),
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Image.network(dadosGif?['images']['original']['url']),
          ),
        ));
  }
}
