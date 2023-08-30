// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:busgiphys/Interface/pagina_gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String? _busca;
  int _offset = 0;

  Future<Map> _pegarGifs() async {
    http.Response resposta;

    final parametrosBusca = {
      'api_key': 'cFEztoWtGyuAkpGaeXRUFFcTSlPjJKlV',
      'q': '$_busca',
      'limit': '19',
      'offset': '$_offset',
      'rating': 'g',
      'lang': 'pt',
      'bundle': 'messaging_non_clips',
    };

    if (_busca == null) {
      resposta =
          await http.get(Uri.https('api.giphy.com', '/v1/gifs/trending', {
        'api_key': 'cFEztoWtGyuAkpGaeXRUFFcTSlPjJKlV',
        'limit': '20',
        'offset': '0',
        'rating': 'g',
        'bundle': 'messaging_non_clips',
      }));
    } else {
      resposta = await http
          .get(Uri.https('api.giphy.com', '/v1/gifs/search', parametrosBusca));
    }

    return json.decode(resposta.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Pesquise aqui!!',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              onSubmitted: (texto) {
                if (texto == '') {
                  setState(() {
                    _busca = null;
                  });
                } else {
                  setState(() {
                    _busca = texto;
                    _offset = 0;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _pegarGifs(),
              builder: (context, instantaneamente) {
                switch (instantaneamente.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  case ConnectionState.done:
                    if (instantaneamente.hasError) {
                      return Center(
                          child: Text(instantaneamente.error.toString()));
                    } else {
                      return _criarTabelaDeGifs(context, instantaneamente);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _quantidadeItens(List dados) {
    if (_busca == null) {
      return dados.length;
    } else {
      return dados.length + 1;
    }
  }

  Widget _criarTabelaDeGifs(
      BuildContext context, AsyncSnapshot instantaneamente) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _quantidadeItens(instantaneamente.data['data']),
      itemBuilder: (context, indice) {
        if (_busca == null || indice < instantaneamente.data['data'].length) {
          return GestureDetector(
            child: Image.network(
              instantaneamente.data['data'][indice]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaginaGif(
                      dadosGif: instantaneamente.data['data'][indice],
                    ),
                  ));
            },
            //1.5 e coloquei também a possibilidade de compartilhar ao segurar
            //em cima da imagem
            onLongPress: () {
                Share.share(instantaneamente.data['data'][indice]['images']['original']['url']);
              },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 70,
                  color: Colors.white,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                )
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          );
        }
      },
    );
  }
}
