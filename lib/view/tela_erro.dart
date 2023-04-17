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
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Future<dynamic> gerarDialogErro(
      BuildContext context, String tituloErro, String mensagem) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(tituloErro),
          content: Text(mensagem),
        );
      },
    );
  }
}
