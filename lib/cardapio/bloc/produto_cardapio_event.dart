import 'package:lanchonete/cardapio/models/produto_cardapio.dart';

abstract class ProdutoCardapioEvent {}

class IniciarStreamProdutosCardapio extends ProdutoCardapioEvent {
  String uid;
  IniciarStreamProdutosCardapio(this.uid);
}

class PararStreamProdutosCardapio extends ProdutoCardapioEvent {}

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
