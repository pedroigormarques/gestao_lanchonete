import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';

abstract class ProdutoCardapioEvent extends StreamEvent {}

class CarregarProdutosCardapio extends ProdutoCardapioEvent {}

class CarregarProdutoCardapio extends ProdutoCardapioEvent {
  final String idProduto;

  CarregarProdutoCardapio(this.idProduto);
}

class AdicionarAoCardapio extends ProdutoCardapioEvent {
  final ProdutoCardapio produto;

  AdicionarAoCardapio(this.produto);
}

class AtualizarProdutoDoCardapio extends ProdutoCardapioEvent {
  final ProdutoCardapio produtoAntigo;
  final ProdutoCardapio produtoAtual;

  AtualizarProdutoDoCardapio(this.produtoAntigo, this.produtoAtual);
}

class RemoverDoCardapio extends ProdutoCardapioEvent {
  final ProdutoCardapio produto;

  RemoverDoCardapio(this.produto);
}
