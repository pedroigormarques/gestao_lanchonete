import 'package:lanchonete/pedidos/models/pedido_fechado.dart';

abstract class PedidoFechadoState {}

class CarregandoPedidosFechados extends PedidoFechadoState {}

class PedidosFechadosCarregados extends PedidoFechadoState {
  final List<PedidoFechado> listaPedidosOriginal;

  final double valorTotal;
  final Map<String, int> produtosCardapioVendidos;
  final Map<String, int> produtosEstoqueUsados;

  PedidosFechadosCarregados(
    this.listaPedidosOriginal,
    this.valorTotal,
    this.produtosCardapioVendidos,
    this.produtosEstoqueUsados,
  );
}

class ErroCarregarPedidosFechados extends PedidoFechadoState {}
