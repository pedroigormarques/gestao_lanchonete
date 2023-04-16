import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';

abstract class PedidoEvent {}

class IniciarStreamPedidos extends PedidoEvent {
  final String uid;
  IniciarStreamPedidos(this.uid);
}

class PararStreamPedidos extends PedidoEvent {}

class CarregarListaPedidos extends PedidoEvent {}

class CarregarPedido extends PedidoEvent {
  final String pedidoId;

  CarregarPedido(this.pedidoId);
}

class AdicionarItemPedido extends PedidoEvent {
  final ProdutoCardapio produtoCardapio;
  final String pedidoId;

  AdicionarItemPedido(this.pedidoId, this.produtoCardapio);
}

class RemoverItemPedido extends PedidoEvent {
  final ProdutoCardapio produtoCardapio;
  final String pedidoId;

  RemoverItemPedido(this.pedidoId, this.produtoCardapio);
}

class AdicionarQuantidadeItemPedido extends PedidoEvent {
  final ProdutoCardapio produtoCardapio;
  final String pedidoId;
  final int quantidade;

  AdicionarQuantidadeItemPedido(this.pedidoId, this.produtoCardapio, this.quantidade);
}

class RemoverQuantidadeItemPedido extends PedidoEvent {
  final ProdutoCardapio produtoCardapio;
  final String pedidoId;
  final int quantidade;

  RemoverQuantidadeItemPedido(this.pedidoId, this.produtoCardapio, this.quantidade);
}

class AdicionarPedido extends PedidoEvent {
  final Pedido pedido;

  AdicionarPedido(this.pedido);
}

class RemoverPedido extends PedidoEvent {
  final Pedido pedido;

  RemoverPedido(this.pedido);
}

class FecharPedido extends PedidoEvent {
  final Pedido pedido;

  FecharPedido(this.pedido);
}
