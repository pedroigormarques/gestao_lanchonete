import 'package:flutter/material.dart';

class TelaCarregamento {
  static Scaffold gerarTelaCarregamento(String tituloDaPagina) {
    return Scaffold(
      appBar: AppBar(title: Text(tituloDaPagina)),
      body: gerarCorpoTelaCarregamento(),
    );
  }

  static Widget gerarCorpoTelaCarregamento() {
    return const Center(child: CircularProgressIndicator());
  }
}
