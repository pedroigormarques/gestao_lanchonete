import 'package:flutter/material.dart';

class DialogConfirmacao {
  static Future<dynamic> gerarDialogConfirmacao(BuildContext context, String pergunta) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(pergunta),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}
