import 'package:lanchonete/provider/stream_provider.dart';

abstract class StreamEvent {}

class NovaNotificacao extends StreamEvent {
  Notificacao notificacao;
  NovaNotificacao(this.notificacao);
}

class IniciarStream extends StreamEvent {
  String uid;
  IniciarStream(this.uid);
}

class PararStream extends StreamEvent {}
