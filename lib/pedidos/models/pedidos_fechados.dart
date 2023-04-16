import 'package:lanchonete/pedidos/models/pedido_fechado.dart';

class ListaPedidosFechados {
  final List<PedidoFechado> _pedidosFechados = [];

  List<PedidoFechado> carregarListaPedidosFechados() => _pedidosFechados;

  void adicionarPedido(PedidoFechado pedido) {
    _pedidosFechados.add(pedido);
  }
}
