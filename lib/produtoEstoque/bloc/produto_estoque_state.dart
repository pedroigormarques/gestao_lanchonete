import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

abstract class ProdutoEstoqueState {}

class CarregandoProdutosEstoque extends ProdutoEstoqueState {}

class ErroCarregarProdutosEstoque extends ProdutoEstoqueState {}

class ProdutosDoEstoqueCarregados extends ProdutoEstoqueState {
  final List<ProdutoEstoque> produtosEstocados;

  ProdutosDoEstoqueCarregados(this.produtosEstocados);
}

class CarregandoProdutoEstoque extends ProdutoEstoqueState {}

class ErroCarregarProdutoEstoque extends ProdutoEstoqueState {}

class ProdutoDoEstoqueCarregado extends ProdutoEstoqueState {
  final ProdutoEstoque produto;

  ProdutoDoEstoqueCarregado(this.produto);
}

abstract class EstadoDeErroProdutoEstoque extends ProdutoEstoqueState {
  final String erro;

  EstadoDeErroProdutoEstoque(this.erro);
}

abstract class EstadoDeSucessoProdutoEstoque extends ProdutoEstoqueState {}

class ErroAoAdicionararProdutoEstoque extends EstadoDeErroProdutoEstoque {
  ErroAoAdicionararProdutoEstoque(String erro) : super(erro);
}

class SucessoAoAdicionarProdutoEstoque extends EstadoDeSucessoProdutoEstoque {}

class ErroAoAtualizarProdutoEstoque extends EstadoDeErroProdutoEstoque {
  ErroAoAtualizarProdutoEstoque(String erro) : super(erro);
}

class SucessoAoAtualizarProdutoEstoque extends EstadoDeSucessoProdutoEstoque {}

class ErroAoRemoverProdutoEstoque extends EstadoDeErroProdutoEstoque {
  ErroAoRemoverProdutoEstoque(String erro) : super(erro);
}

class SucessoAoRemoverProdutoEstoque extends EstadoDeSucessoProdutoEstoque {}
