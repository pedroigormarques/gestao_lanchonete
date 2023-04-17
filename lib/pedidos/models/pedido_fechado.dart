import 'package:flutter/foundation.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';

class PedidoFechado {
  late final int mesa;
  final Map<String, int> _produtosVendidos = {};
  final Map<String, int> _produtosUtilizados = {};
  late final double valorConta;

  late final DateTime horaAbertura;
  late final DateTime _horaFechamento;

  PedidoFechado(Pedido pedido) {
    _horaFechamento = DateTime.now();
    mesa = pedido.mesa;
    valorConta = pedido.valorConta;
    horaAbertura = pedido.horaAbertura;

    pedido.produtosVendidos.forEach((produtoVendido, quantidade) {
      _produtosVendidos[produtoVendido.nomeProduto] = quantidade;

      produtoVendido.composicao.forEach((produtoUsado, qtd) {
        if (!_produtosUtilizados.containsKey(
            "${produtoUsado.nomeProduto} ( em ${describeEnum(produtoUsado.unidade)})")) {
          _produtosUtilizados[
              "${produtoUsado.nomeProduto} ( em ${describeEnum(produtoUsado.unidade)})"] = 0;
        }
        _produtosUtilizados.update(
            "${produtoUsado.nomeProduto} ( em ${describeEnum(produtoUsado.unidade)})",
            (value) => value + qtd * quantidade);
      });
    });
  }

  PedidoFechado.fromMap(map) {
    mesa = map["mesa"];
    valorConta = double.parse(map["valorConta"].toString());

    List produtosUtilizadosPedido = map["produtosUtilizados"];
    for (dynamic item in produtosUtilizadosPedido) {
      _produtosUtilizados[
          "${item[0]['nomeProduto']} ( em ${item[0]['unidade']})"] = item[1];
    }

    List dados = map["produtosVendidos"];
    for (dynamic item in dados) {
      _produtosVendidos[item[0]['nomeProduto']] = item[1];
    }

    horaAbertura = DateTime.parse(map["horaAbertura"]).toLocal();
    _horaFechamento = DateTime.parse(map["horaFechamento"]).toLocal();
  }

  toMap() {
    Map<String, dynamic> map = {};
    map["mesa"] = mesa;
    map["valorConta"] = valorConta;
    map["horaAbertura"] = horaAbertura.toString();
    map["horaFechamento"] = _horaFechamento.toString();
    map["produtosVendidos"] = _produtosVendidos;
    map["produtosUtilizados"] = _produtosUtilizados;
    return map;
  }

  Map<String, int> get produtosUtilizados => {..._produtosUtilizados};
  Map<String, int> get produtosVendidos => {..._produtosVendidos};
}
