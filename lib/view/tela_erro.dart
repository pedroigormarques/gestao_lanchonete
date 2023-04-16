import 'package:flutter/material.dart';

class TelaErro {
  static Scaffold gerarTelaErro(String tituloDaPagina, String erro) {
    return Scaffold(
      appBar: AppBar(title: Text(tituloDaPagina)),
      body: gerarCorpoTelaErro(erro),
    );
  }

  static Widget gerarCorpoTelaErro(String erro) {
    return Center(
      child: Text(
        erro,
        style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
