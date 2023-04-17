import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';

abstract class StreamBloc<Event extends StreamEvent, State>
    extends Bloc<StreamEvent, State> {
  final StreamProvider _provider;
  StreamSubscription<Notificacao>? _listener;

  StreamBloc(this._provider, State estadoInicial) : super(estadoInicial) {
    on<NovaNotificacao>(notificarAtualizacao);
    on<IniciarStream>(_iniciarStream);
    on<PararStream>(_pararStream);
  }

  @protected
  void notificarAtualizacao(NovaNotificacao event, Emitter<State> emit);

  void _iniciarStream(IniciarStream event, Emitter<State> emit) {
    _provider.setUid(event.uid);

    _listener = _provider.stream.listen(
      (Notificacao notificacao) => add(NovaNotificacao(notificacao)),
      onError: (erro) {
        add(NovaNotificacao(Notificacao(
          TipoNotificacao.erroConexao,
          mensagem: 'erro externo: ' + erro.toString(),
        )));
      },
    );
  }

  Future<void> _pararStream(PararStream event, Emitter<State> emit) async {
    await _listener?.cancel();
    _provider.limparDados();
  }
}
