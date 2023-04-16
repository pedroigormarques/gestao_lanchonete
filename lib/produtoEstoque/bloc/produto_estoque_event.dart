import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

abstract class ProdutoEstoqueEvent {}

class IniciarStreamProdutosEstoque extends ProdutoEstoqueEvent {
  String uid;
  IniciarStreamProdutosEstoque(this.uid);
}

class PararStreamProdutosEstoque extends ProdutoEstoqueEvent {}

class CarregarProdutosEstoque extends ProdutoEstoqueEvent {}

class CarregarProdutoEstoque extends ProdutoEstoqueEvent {
  final String idProduto;

  CarregarProdutoEstoque(this.idProduto);
}

class AdicionarAoEstoque extends ProdutoEstoqueEvent {
  final ProdutoEstoque produto;

  AdicionarAoEstoque(this.produto);
}

class AtualizarProdutoDoEstoque extends ProdutoEstoqueEvent {
  final ProdutoEstoque produtoEstoque;

  AtualizarProdutoDoEstoque(this.produtoEstoque);
}

class RemoverDoEstoque extends ProdutoEstoqueEvent {
  final String idProduto;

  RemoverDoEstoque(this.idProduto);
}
