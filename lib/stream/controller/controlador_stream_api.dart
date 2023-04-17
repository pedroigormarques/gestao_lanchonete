import 'dart:async';
import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:flutter/material.dart';
import 'package:lanchonete/provider/conexao/eventsource_controller.dart';

enum StatusConexao { conectado, erroConexao, desconectado, conectando }

class ErroStatus {
  StatusConexao statusConexao;
  String? erro;
  ErroStatus(this.statusConexao, {this.erro});
}

class ControladorStreamAPI {
  StatusConexao _statusConexao = StatusConexao.desconectado;
  bool _tentarReconexao = false;

  final String _url;
  final StreamController<List<Map>> _streamController =
      StreamController<List<Map>>.broadcast();
  StreamSubscription? _listenerControlado;

  Event? lastEvent;

  Stream<List<Map>> get stream => _streamController.stream;
  StatusConexao get statusConexao => _statusConexao;

  ControladorStreamAPI(this._url);

  Future<void> iniciarConexao() async {
    _tentarReconexao = true;
    lastEvent = null;
    await _abrirConexao();
  }

  Future<void> fecharConexao() async {
    _tentarReconexao = false;
    await _listenerControlado?.cancel();
    _statusConexao = StatusConexao.desconectado;
  }
  /*{
        'status': _streamControlada?.readyState.toString(),
        'info': _streamControlada?.client.toString(),
        'headers': _streamControlada?.headers.toString(),
        'isBroadcast': _streamControlada?.isBroadcast.toString(),
        'pausado': _listenerControlado?.isPaused.toString(),
      }*/

  Future<void> _abrirConexao() async {
    try {
      _alterarEstadoParaConectando();

//erro duplicando a resposta ao desconectar e conectar rapidamente
      EventSource _streamControlada = await EventSourceController.connect(_url)
          .whenComplete(_alterarEstadoParaConectado);

      bool posteriorUltimoEvento = (lastEvent == null) ? true : false;
      _listenerControlado = _streamControlada.listen(
        (event) {
          //rever questão do id
          if (posteriorUltimoEvento) {
            lastEvent = event;
            if (event.data != null) {
              List<Map> dados = json.decode(event.data!).cast<Map>().toList();
              _streamController.add(dados);
            }
          } else if (event == lastEvent) {
            posteriorUltimoEvento = true;
          }
        },
        onError: _alterarParaEstadoDeErro,
        onDone: () => debugPrint('done controlador'),
        cancelOnError: true,
      );
    } on FormatException catch (erro) {
      _alterarParaEstadoDeErro(erro);

      if (_tentarReconexao) {
        debugPrint('Nova tentativa de conexao em 5 segundos');
        await Future.delayed(const Duration(seconds: 5));
      }

      if (_tentarReconexao) {
        debugPrint('Reconectando...');
        await _abrirConexao();
      } else {
        debugPrint('Tentativa de reconexão cancelada');
      }
    }
  }

  void _alterarParaEstadoDeErro(Object erro) {
    _statusConexao = StatusConexao.erroConexao;

    String message = erro is FormatException ? erro.message : erro.toString();
    debugPrint(message);
    _streamController.addError(
      ErroStatus(StatusConexao.erroConexao, erro: message),
    );
  }

  void _alterarEstadoParaConectando() {
    _statusConexao = StatusConexao.conectando;
    _streamController.addError(ErroStatus(StatusConexao.conectando));
  }

  void _alterarEstadoParaConectado() {
    _statusConexao = StatusConexao.conectado;
    _streamController.add([]); //para avisar evento de conexão
  }
}
