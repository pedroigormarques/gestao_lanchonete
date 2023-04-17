import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lanchonete/provider/conexao/controlador_estado_app.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';

enum TipoNotificacao {
  novoDado,
  conectando,
  erroConexao,
}

class Notificacao {
  TipoNotificacao tipoNotificacao;
  String? mensagem;
  Notificacao(this.tipoNotificacao, {this.mensagem});
}

abstract class StreamProvider {
  final String _urlStream;
  bool _jaConectado = false;

  StreamSubscription<void>? _listener;

  StatusConexao get statusConexao =>
      _controladorStreamApi.statusConexao; //-------------

  late ControladorStreamAPI _controladorStreamApi;
  late final StreamController<Notificacao> _streamController;

  Stream<Notificacao> get stream => _streamController.stream;

  StreamProvider(this._urlStream) {
    _controladorStreamApi = ControladorStreamAPI(_urlStream);
    _streamController = StreamController<Notificacao>.broadcast(
      onListen: () => ControladorApp.addStreamProvider(this),
      onCancel: () => ControladorApp.removerStreamProvider(this),
    );
  }

  // rever
  String? _uid;
  void setUid(String uid) => _uid = uid;
  @protected
  String? get uid => _uid;
  void limparDados() => _uid = null;

  @protected
  void criarRepositorioDados();
  @protected
  void limparRepositorioDados();
  @protected
  void mapFunction(List<Map> dados);

  @protected
  bool precondicaoConluida() => true;
  @protected
  String gerarMensagemErroPrecondicao() => 'Pré-condição não concluída';

  //interno
  Future<void> finalizarConexao() async {
    await _listener?.cancel();
    _listener = null;
    await _controladorStreamApi.fecharConexao();
    limparRepositorioDados();
  }

  //interno
  Future<void> iniciarConexao() async {
    _listener = _gerarListener();
    await _iniciarControlador();
  }

  Future<void> _iniciarControlador() async {
    try {
      debugPrint('função iniciarConexaoControlador');
      _jaConectado = false;
      limparRepositorioDados();
      await _esperarPrecondicaoSerValida();
      debugPrint(gerarMensagemErroPrecondicao());
      await _controladorStreamApi.iniciarConexao().whenComplete(
        () async {
          if (_listener != null) {
            criarRepositorioDados();
            _jaConectado = true;
          } else {
            await finalizarConexao();
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//-*---------
  Future<void> _esperarPrecondicaoSerValida() async {
    while (_listener != null) {
      /*_streamController.add(Notificacao(TipoNotificacao.conectando));
      await Future.delayed(const Duration(seconds: 1));*/
      if (precondicaoConluida() && _listener != null) {
        break;
      } else {
        _streamController.add(Notificacao(
          TipoNotificacao.erroConexao,
          mensagem: gerarMensagemErroPrecondicao(),
        ));
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    // finaliza o loop externo lançando um erro
    if (_listener == null) throw 'Conexao cancelada';
  }

  StreamSubscription<void> _gerarListener() {
    return _controladorStreamApi.stream.asyncMap(mapFunction).listen(
      (_) => _streamController.add(Notificacao(TipoNotificacao.novoDado)),
      onError: (Object erro) async {
        if (erro is ErroStatus) {
          if (erro.statusConexao == StatusConexao.conectando) {
            _streamController.add(Notificacao(TipoNotificacao.conectando));
          } else {
            _streamController.add(
              Notificacao(TipoNotificacao.erroConexao, mensagem: erro.erro),
            );
            if (_jaConectado) await _iniciarControlador();
          }
        } else {
          _streamController.addError(erro);
        }
      },
    );
  }
}
