
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';

abstract class ProdutoCardapioState{}

class CarregandoProdutosCardapio extends ProdutoCardapioState {}

class ErroCarregarProdutosCardapio extends ProdutoCardapioState {}

class ProdutosDoCardapioCarregados extends ProdutoCardapioState {
  final List<ProdutoCardapio> produtosCardapio;

  ProdutosDoCardapioCarregados(this.produtosCardapio);
}

class CarregandoProdutoCardapio extends ProdutoCardapioState {}

class ErroCarregarProdutoCardapio extends ProdutoCardapioState {}

class ProdutoDoCardapioCarregado extends ProdutoCardapioState {
  final ProdutoCardapio produto;

  ProdutoDoCardapioCarregado(this.produto);
}

abstract class EstadoDeErroProdutoCardapio extends ProdutoCardapioState {
  final String erro;

  EstadoDeErroProdutoCardapio(this.erro);
}

abstract class EstadoDeSucessoProdutoCardapio extends ProdutoCardapioState {}

class ErroAoAdicionarProdutoCardapio extends EstadoDeErroProdutoCardapio {
  ErroAoAdicionarProdutoCardapio(String erro) : super(erro);
}

class SucessoAoAdicionarProdutoCardapio extends EstadoDeSucessoProdutoCardapio {}

class ErroAoAtualizarProdutoCardapio extends EstadoDeErroProdutoCardapio {
  ErroAoAtualizarProdutoCardapio(String erro) : super(erro);
}

class SucessoAoAtualizarProdutoCardapio extends EstadoDeSucessoProdutoCardapio {}

class ErroAoRemoverProdutoCardapio extends EstadoDeErroProdutoCardapio {
  ErroAoRemoverProdutoCardapio(String erro) : super(erro);
}

class SucessoAoRemoverProdutoCardapio extends EstadoDeSucessoProdutoCardapio {}
