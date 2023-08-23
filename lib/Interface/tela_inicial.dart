// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

    //_pegarGifs().then((value) => print('teste: $value'));
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
              //1.1 o onSubmitted realizar o "comando" qnd dou um ok no teclado
              //ou um enter no teclado desktop
              onSubmitted: (texto) {
                setState(() {
                  _busca = texto;
                  //1.9 a cada pesquisa zero o offset para mostrar os primeiros
                  //gifs da lista
                  _offset = 0;
                });
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

  //1.2 função para add + 1 espaço para eu colocar um botão de "ver mais" no
  //final da lista
  int _quantidadeItens(List dados) {
    if (_busca == null) {
      //1.3 se não for busca, carregar apenas o tamanho da lista de fato
      return dados.length;
    } else {
      //1.4 se for busca, colocar um espaço a mais
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
      //1.5 o retorno dessa função será a quantidade de itens na minha grade
      //A lista analisada será a lista de gifs retornada
      itemCount: _quantidadeItens(instantaneamente.data['data']),
      itemBuilder: (context, indice) {
        //1.6 se eu não estiver realizando uma busca, carregar o gif
        //Se o indice/posição estiver dentro do tamanho da lista, carregar o
        //gif da lista
        //Ou seja, qnd eu estiver buscando e acabar os gifs da lista...[1.7]
        if (_busca == null || indice < instantaneamente.data['data'].length) {
          return GestureDetector(
            child: Image.network(
              instantaneamente.data['data'][indice]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
          );
          //1.7 aparecer a opção de "carregar mais" gifs
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
            //1.8 ao clicar em carregar mais, mostrar mais 19 gifs da base de gifs
            //Isso funcionará pois o futureBuilder será recarregado, rodando assim
            //novamente a montagem do gridview e continuará a contagem do itemCount
            //pois o offset será definido em +19 assim então pulará o carregamento
            //dos primeiros [valor do offset] da lista
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
