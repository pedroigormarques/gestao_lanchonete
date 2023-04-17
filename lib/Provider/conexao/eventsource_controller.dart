import 'package:eventsource/eventsource.dart';
import 'package:lanchonete/provider/conexao/dio_controller.dart';
import 'package:lanchonete/provider/manipulador_erro.dart';

class EventSourceController {
  static get _segundosToleranciaCarregamento => 5;
  static Future<EventSource> connect(String url) async {
    EventSource conexao = await EventSource.connect(
      url,
      headers: {
        "Authorization": DioController.instance.autorizacao,
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
      },
    )
        .timeout(Duration(seconds: _segundosToleranciaCarregamento),
            onTimeout: () => throw const FormatException('Timeout'))
        .onError((e, _) async {
      if (e is EventSourceSubscriptionException) {
        if (e.statusCode == 401) {
          try {
            await DioController.instance.renovarAutorizacao();
            return await connect(url);
          } catch (_) {
            rethrow;
          }
        }
        throw FormatException(e.data.toString());
      }
      throw ManipuladorErro.gerarErro(e);
    });

    return conexao;
  }
}
