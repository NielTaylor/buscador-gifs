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
  final int _offset = 0;

  Future<Map> _pegarGifs() async {
    http.Response response;

    final parametrosBusca = {
      'api_key': 'cFEztoWtGyuAkpGaeXRUFFcTSlPjJKlV',
      'q': '$_busca',
      'limit': '25',
      'offset': '$_offset',
      'rating': 'g',
      'lang': 'pt',
      'bundle': 'clips_grid_picker',
    };

    if (_busca == null) {
      response =
          await http.get(Uri.https('api.giphy.com', '/v1/gifs/trending', {
        'api_key': 'cFEztoWtGyuAkpGaeXRUFFcTSlPjJKlV',
        'limit': '20',
        'offset': '0',
        'rating': 'g',
        'bundle': 'messaging_non_clips',
      }));
    } else {
      response = await http
          .get(Uri.https('api.giphy.com', '/v1/gifs/search', parametrosBusca));
    }

    return json.decode(response.body);
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
                      return Container();
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

  Widget _criarTabelaDeGifs(
      BuildContext context, AsyncSnapshot instantaneamente) {
    //1.1 o GridView é o que irá criar a grade de gifs. Acho que ele é com
    //builder pq ele será construído de acordo com mudanças em algo
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        //1.2 espaço endre as bordas da tela
        padding: EdgeInsets.all(10),
        //1.3 o grid delegate acho q é o que define o estilo de montagem da grade
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //1.4 defini quantos item ele pode ter na horizontal
          crossAxisCount: 2,
          //1.5 espaçamento entre os itens na horizontal
          crossAxisSpacing: 10,
          //1.6 espaçamento na vertical
          mainAxisSpacing: 10,
        ),
        //2.1 passei então para a qntdade de itens a serem mostrado ser a
        //quantidade de itens defini para a api de gifs trendings retornar
        //Como todo os gifs estão dentro de 'data', passei para ser pego então
        //de fato o  comprimento de 'data'
        //1.7 quantidade de grades/itens a serem mostrados
        itemCount: instantaneamente.data['data'].length,
        //1.8 no itemBuilder deve ter uma função que retorna o widget que
        //colocarem em cada posição/index/indice
        //Para cada item que for construído será chamada a função que passarmos
        //nele, e o widget que essa função retornar é o que será mostrado na
        //posição/indice/index em questão (é parecido com um for que carrega
        //uma lista)
        itemBuilder: (context, indice) {
          //1.9 quermos que em cada posição seja colocada uma imagem, mas como
          //quero q após o clique na imagem aconteça alguma coisa, irei colocar
          //a imagem em um GestureDetector
          return GestureDetector(
            //1.8 aí então passo a minha imagem que estará na variável que
            //armazena o json/dados obtidos no FutureBuilder, e q o
            //FutureBuilder pegou do _pegarGifs()
            child: Image.network(
              instantaneamente.data['data'][indice]['images']['fixed_height']
                  ['url'],
              //1.9 após a vírgula acima posso passar então outros atributos p/
              //a imagem),
              height: 300,
              fit: BoxFit.cover,
              //passei a altura e como a imagem deve se encaixar no espaço alocado
            ),
          );
        },
      ),
    );
  }
}
