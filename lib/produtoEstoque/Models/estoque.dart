import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

class Estoque {
  final List<ProdutoEstoque> _itens = [];

  Estoque();

  List<ProdutoEstoque> carregarProdutos() => _itens;

  ProdutoEstoque carregarProduto(String idProduto) {
    return _itens[_posicaoListaPeloId(idProduto)];
  }

  int _posicaoListaPeloId(String idProduto) {
    int p = _itens.indexWhere(
      (produto) => produto.id == idProduto,
    );
    if (p == -1) {
      throw Exception("Produto com este id não encontrado!");
    } else {
      return p;
    }
  }

  void adicionarProduto(ProdutoEstoque produto) {
    _itens.add(produto);
    _itens.sort(((a, b) => a.compareTo(b)));
  }

  void atualizarProduto(ProdutoEstoque produto) {
    _itens[_posicaoListaPeloId(produto.id)].atualizarDados(produto);
    _itens.sort((a, b) => a.compareTo(b));
  }

  void removerProduto(String idProduto) => _itens.remove(_itens[_posicaoListaPeloId(idProduto)]);
}
