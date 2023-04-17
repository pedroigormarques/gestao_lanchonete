import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lanchonete/provider/conexao/controlador_estado_app.dart';
import 'package:lanchonete/provider/conexao/dados_provider.dart';
import 'package:lanchonete/provider/conexao/dio_controller.dart';
import 'package:lanchonete/provider/manipulador_erro.dart';
import 'package:lanchonete/login/models/usuario.dart';

class UsuarioService {
  final _urlBaseUsuario = DadosProvider.localUsuario;
  final Dio _dioSemCabecalho = DioController.dioSemCabecalho;
  final Dio _dioComCabecalho = DioController.instance.dioAreaRestrita;

  final StreamController<Usuario?> streamController =
      StreamController<Usuario?>();
  Stream<Usuario?> get stream => streamController.stream;

  Usuario? _usuario;
  /*UsuarioService() {
    ControladorEstadoApp.stream.listen((event) {
      if (event == AppLifecycleState.resumed) {
        //ler dados do arquivo com o usuario atual
        streamController.add(_usuario);
      }
    });
  }*/

  Future<void> logar(String email, String senha) async {
    try {
      Response response = await _dioSemCabecalho.post(
        _urlBaseUsuario + '/entrar',
        data: {'email': email, 'senha': senha},
      );

      DioController.instance
          .setDadosAcessoLogin(response.data['token'], email, senha);

      _notificarAlteracaoUsuario(Usuario.fromMap(response.data['usuario']));
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro, logado: false);
    }
  }

  Future<void> deslogar() async {
    DioController.instance.limparDadosAcesso();
    _notificarAlteracaoUsuario(null);
  }

  Future<void> registrar(String email, String senha, String nomeLanchonete,
      String endereco) async {
    try {
      await _dioSemCabecalho.post(
        _urlBaseUsuario + '/registrar',
        data: {
          "email": email,
          "senha": senha,
          "endereco": endereco,
          "nomeLanchonete": nomeLanchonete
        },
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro, logado: false);
    }
  }

  Future<Response> atualizar(
      {String? email,
      String? senha,
      String? nomeLanchonete,
      String? endereco}) async {
    try {
      var dados = {};
      if (email != null) dados['email'] = email;
      if (senha != null) dados['senha'] = senha;
      if (nomeLanchonete != null) dados['nomeLanchonete'] = nomeLanchonete;
      if (endereco != null) dados['endereco'] = endereco;

      return await _dioComCabecalho.put(
        _urlBaseUsuario + '/atualizar',
        data: dados,
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> atualizarInformacoes(
      String nomeLanchonete, String endereco) async {
    try {
      var response =
          await atualizar(nomeLanchonete: nomeLanchonete, endereco: endereco);
      _notificarAlteracaoUsuario(Usuario.fromMap(response.data));
    } catch (_) {
      rethrow;
    }
  }

//ver uso da senha atual
  Future<void> atualizarEmailAcesso(String senhaAtual, String novoEmail) async {
    try {
      var response = await atualizar(email: novoEmail);
      DioController.instance.setEmailRenovacaoToken(novoEmail);
      _notificarAlteracaoUsuario(Usuario.fromMap(response.data));
    } catch (_) {
      rethrow;
    }
  }

//ver uso da senha atual
  Future<void> atualizarSenhaAcesso(String senhaAtual, String novaSenha) async {
    try {
      await atualizar(senha: novaSenha);
      DioController.instance.setEmailRenovacaoToken(novaSenha);
    } catch (_) {
      rethrow;
    }
  }

  void _notificarAlteracaoUsuario(Usuario? usuario) {
    streamController.add(usuario);
    _usuario = usuario;
  }
}
