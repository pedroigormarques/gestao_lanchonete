import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lanchonete/Provider/usuario_firebase_provider.dart';
import 'package:lanchonete/login/bloc/autenticacao_event.dart';
import 'package:lanchonete/login/bloc/autenticacao_state.dart';
import 'package:lanchonete/login/models/usuario.dart';

class AutenticacaoBloc extends Bloc<AutenticacaoEvent, AutenticacaoState> {
  final UsuarioService _autenticacaoService = UsuarioService();

  AutenticacaoBloc() : super(Desautenticado()) {
    _autenticacaoService.usuario.listen((event) {
      add(EventoAutenticacaoDoServidor(event));
    });

    on<EventoAutenticacaoDoServidor>(_emitirRespostaServidor);
    on<RegistrarUsuario>(_registrar);
    on<AtualizarInformacoes>(_atualizarInformacoes);
    on<AtualizarEmail>(_atualizarEmail);
    on<AtualizarSenha>(_atualizarSenha);
    on<LogarUsuario>(_logar);
    on<Deslogar>(_deslogar);
  }

  _emitirRespostaServidor(EventoAutenticacaoDoServidor event, Emitter<AutenticacaoState> emit) {
    if (event.usuario == null) {
      emit(Desautenticado());
    } else {
      emit(Autenticado(event.usuario!));
    }
  }

  _registrar(RegistrarUsuario event, Emitter<AutenticacaoState> emit) async {
    try {
      await _autenticacaoService.registrar(event.email, event.senha, event.nomeLanchonete, event.endereco);
    } on FormatException catch (e) {
      emit(ErroDeAutenticacao("Erro ao Registrar!", e.message));
    }
  }

  _logar(LogarUsuario event, Emitter<AutenticacaoState> emit) async {
    try {
      await _autenticacaoService.logar(event.email, event.senha);
    } on FormatException catch (e) {
      emit(ErroDeAutenticacao("Erro ao logar!", e.message));
    }
  }

  _deslogar(Deslogar event, Emitter<AutenticacaoState> emit) async {
    Usuario usuario = (state as Autenticado).usuario;
    try {
      await _autenticacaoService.deslogar();
    } on FormatException catch (e) {
      emit(ErroDeAutenticacao("Erro ao deslogar!", e.message));
      emit(Autenticado(usuario));
    }
  }

  _atualizarInformacoes(AtualizarInformacoes event, Emitter<AutenticacaoState> emit) async {
    Usuario usuario = (state as Autenticado).usuario;
    try {
      await _autenticacaoService.atualizarInformacoes(event.nomeLanchonete, event.endereco);
      usuario = Usuario(usuario.uid, usuario.email, event.nomeLanchonete, event.endereco);
      emit(SucessoAtualizacao("Dados alterados com sucesso"));
    } on FormatException catch (e) {
      emit(ErroAtualizacao(e.message));
    } finally {
      emit(Autenticado(usuario));
    }
  }

  _atualizarEmail(AtualizarEmail event, Emitter<AutenticacaoState> emit) async {
    Usuario usuario = (state as Autenticado).usuario;
    try {
      await _autenticacaoService.atualizarEmailAcesso(event.senhaAtual, event.novoEmail);
      emit(SucessoAtualizacao("Email alterado com sucesso"));
    } on FormatException catch (e) {
      emit(ErroAtualizacao(e.message));
      emit(Autenticado(usuario));
    }
  }

  _atualizarSenha(AtualizarSenha event, Emitter<AutenticacaoState> emit) async {
    Usuario usuario = (state as Autenticado).usuario;
    try {
      await _autenticacaoService.atualizarSenhaAcesso(event.senhaAtual, event.novaSenha);
      emit(SucessoAtualizacao("Senha alterada com sucesso"));
    } on FormatException catch (e) {
      emit(ErroAtualizacao(e.message));
      emit(Autenticado(usuario));
    }
  }
}
