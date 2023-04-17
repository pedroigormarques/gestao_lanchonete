import 'package:flutter/cupertino.dart';
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

  static Future<dynamic> gerarDialogCarregando(
      BuildContext context, String mensagem) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 32)),
                gerarCorpoTelaCarregamento(),
              ],
            ),
          ),
        );
      },
    );
  }
}
