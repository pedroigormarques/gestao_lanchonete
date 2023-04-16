import 'package:flutter/material.dart';

class NotificacaoSnackBar {
  static void gerarSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(backgroundColor: Colors.grey[600],duration: const Duration(seconds: 2), content: Text(mensagem)),
      );
  }
}
