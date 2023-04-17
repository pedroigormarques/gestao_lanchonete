import 'package:lanchonete/login/models/usuario.dart';

class UsuarioLogado {
  Usuario usuario;
  final String token;
  UsuarioLogado(this.token, this.usuario);
}
