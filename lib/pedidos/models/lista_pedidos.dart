import 'package:lanchonete/pedidos/models/pedido.dart';

class ListaPedidos {
  final List<Pedido> _pedidos = [];

  ListaPedidos();

  List<Pedido> carregarListaPedidos() => _pedidos;

  Pedido carregarPedido(String idPedido) {
    return _pedidos[_posicaoListaPeloId(idPedido)];
  }

  int _posicaoListaPeloId(String idPedido) {
    int p = _pedidos.indexWhere(
      (pedido) => pedido.id == idPedido,
    );
    if (p == -1) {
      throw Exception("Pedido com este id não encontrado!");
    } else {
      return p;
    }
  }

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    _pedidos.sort((a, b) => a.compareTo(b));
  }

  void atualizarPedido(Pedido pedido) {
    _pedidos[_posicaoListaPeloId(pedido.id)].atualizarDados(pedido);
    _pedidos.sort((a, b) => a.compareTo(b));
  }

  void removerPedido(String idPedido) => _pedidos.removeAt(_posicaoListaPeloId(idPedido));

}
