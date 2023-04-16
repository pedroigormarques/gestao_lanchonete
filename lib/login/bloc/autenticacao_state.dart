import 'package:lanchonete/login/models/usuario.dart';

abstract class AutenticacaoState {}

class Desautenticado extends AutenticacaoState {}

class Autenticado extends AutenticacaoState {
  Usuario usuario;
  Autenticado(this.usuario);
}

class ErroDeAutenticacao extends AutenticacaoState {
  final String tituloErro;
  final String mensagem;

  ErroDeAutenticacao(this.tituloErro, this.mensagem);
}

class ErroAtualizacao extends AutenticacaoState {
  final String erro;

  ErroAtualizacao(this.erro);
}

class SucessoAtualizacao extends AutenticacaoState {
  final String mensagem;

  SucessoAtualizacao(this.mensagem);
}
