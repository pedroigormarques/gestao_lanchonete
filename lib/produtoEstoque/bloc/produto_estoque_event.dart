import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';

abstract class ProdutoEstoqueEvent extends StreamEvent {}

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
