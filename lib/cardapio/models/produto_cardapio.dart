import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

enum CATEGORIAS { bebidas, lanches, sobremesas }

class ProdutoCardapio implements Comparable<ProdutoCardapio> {
  late String id;

  late String nomeProduto;
  late String descricao;
  Map<ProdutoEstoque, int> composicao = {};
  late double _preco;
  late CATEGORIAS categoria;

  ProdutoCardapio(this.nomeProduto, this.descricao, double preco, this.categoria, this.composicao, {String? id}) {
    this.preco = preco;
    if (id != null) {
      this.id = id;
    }
  }

  ProdutoCardapio.fromMap(map, List<ProdutoEstoque> produtosEstoque) {
    nomeProduto = map["nomeProduto"];
    descricao = map["descricao"];
    _preco = map["preco"];
    categoria = CATEGORIAS.values.byName(map["categoria"]);
    (map["composicao"] as Map).forEach((key, value) {
      composicao[produtosEstoque.firstWhere((element) => element.id == key)] = value;
    });
  }

  toMap() {
    Map<String, dynamic> map = {};
    map["nomeProduto"] = nomeProduto;
    map["descricao"] = descricao;
    map["preco"] = _preco;
    map["categoria"] = categoria.name;
    map["composicao"] = composicao.map((produtoEstoque, quantidade) => MapEntry<String, int>(produtoEstoque.id, quantidade));
    return map;
  }

  double get preco {
    return _preco;
  }

  set preco(p) {
    if (p < 0) {
      throw const FormatException("Valor inválido para o preço");
    } else {
      _preco = double.parse(p.toStringAsFixed(2));
    }
  }

  int visualizarQuantidade() {
    int max = -1;
    composicao.forEach((pe, qtd) {
      int disponivel = pe.quantidade ~/ qtd;
      if (max == -1 || disponivel < max) {
        max = disponivel;
      }
    });
    return max;
  }

  void removerQuantidade(int val) {
    if (val <= 0) {
      throw const FormatException("Valor inválido para realizar a remoção");
    } else if (visualizarQuantidade() < val) {
      throw const FormatException("Quantidade insuficiente para realizar a remoção");
    } else {
      composicao.forEach((key, value) {
        key.removerQuantidade(value * val);
      });
    }
  }

  void retornarQuantidade(int val) {
    if (val <= 0) {
      throw const FormatException("Valor inválido para realizar a adição");
    } else {
      composicao.forEach((key, value) {
        key.adicionarQuantidade(value * val);
      });
    }
  }

  @override
  int compareTo(ProdutoCardapio other) {
    int aux = categoria.name.compareTo(other.categoria.name);
    if (aux != 0) {
      return aux;
    } else {
      return nomeProduto.compareTo(other.nomeProduto);
    }
  }

  void atualizarDados(ProdutoCardapio produto) {
    nomeProduto = produto.nomeProduto;
    descricao = produto.descricao;
    composicao = produto.composicao; 
    _preco = produto._preco;
    categoria = produto.categoria;
  }
}
