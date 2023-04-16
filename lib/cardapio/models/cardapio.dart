
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';

class Cardapio {
  final List<ProdutoCardapio> _itens = [];

  Cardapio();

  List<ProdutoCardapio> carregarProdutos() => _itens;

  ProdutoCardapio carregarProduto(String idProduto) {
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

  void adicionarProduto(ProdutoCardapio produto) {
    _itens.add(produto);
    _itens.sort((a, b) => a.compareTo(b));
  }

  void atualizarProduto(ProdutoCardapio produto) {
    _itens[_posicaoListaPeloId(produto.id)].atualizarDados(produto);
    _itens.sort((a, b) => a.compareTo(b));    
  }

  void removerProduto(String idProduto) => _itens.remove(_itens[_posicaoListaPeloId(idProduto)]);
}
