import 'package:lanchonete/login/models/usuario.dart';

abstract class AutenticacaoEvent {}

class RegistrarUsuario extends AutenticacaoEvent {
  String email;
  String senha;
  String nomeLanchonete;
  String endereco;

  RegistrarUsuario(this.email, this.senha, this.nomeLanchonete, this.endereco);
}

class AtualizarInformacoes extends AutenticacaoEvent {
  String nomeLanchonete;
  String endereco;

  AtualizarInformacoes(this.nomeLanchonete, this.endereco);
}

class AtualizarEmail extends AutenticacaoEvent {
  String novoEmail;
  String senhaAtual;

  AtualizarEmail(this.novoEmail, this.senhaAtual);
}

class AtualizarSenha extends AutenticacaoEvent {
  String novaSenha;
  String senhaAtual;

  AtualizarSenha(this.senhaAtual, this.novaSenha);
}

class LogarUsuario extends AutenticacaoEvent {
  String email;
  String senha;

  LogarUsuario(this.email, this.senha);
}

class Deslogar extends AutenticacaoEvent {}

class EventoAutenticacaoDoServidor extends AutenticacaoEvent {
  final Usuario? usuario;
  EventoAutenticacaoDoServidor(this.usuario);
}
