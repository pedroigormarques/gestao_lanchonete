enum UNIDADE { kg, g, L, ml, un, pc, lt }

class ProdutoEstoque implements Comparable<ProdutoEstoque> {
  late String id;

  late String nomeProduto;
  late String descricao;
  late int _quantidade;
  late UNIDADE unidade;

  ProdutoEstoque(this.nomeProduto, this.descricao, quantidade, this.unidade, {String? id}) {
    this.quantidade = quantidade;
    if (id != null) {
      this.id = id;
    }
  }

  ProdutoEstoque.fromMap(map) {
    nomeProduto = map["nomeProduto"];
    descricao = map["descricao"];
    _quantidade = map["quantidade"];
    unidade = UNIDADE.values.byName(map["unidade"]);
  }

  toMap() {
    Map<String, dynamic> map = {};
    map["nomeProduto"] = nomeProduto;
    map["descricao"] = descricao;
    map["quantidade"] = quantidade;
    map["unidade"] = unidade.name;
    return map;
  }

  set quantidade(qtd) {
    if (qtd < 0) {
      throw const FormatException("Valor inválido para a quantidade");
    } else {
      _quantidade = qtd;
    }
  }

  int get quantidade {
    return _quantidade;
  }

  void removerQuantidade(int val) {
    if (val <= 0) {
      throw const FormatException("Valor inválido para realizar a remoção do estoque");
    } else if (quantidade < val) {
      throw const FormatException("Quantidade insuficiente para realizar a remoção do estoque");
    } else {
      _quantidade -= val;
    }
  }

  void adicionarQuantidade(int val) {
    if (val <= 0) {
      throw const FormatException("Valor inválido para realizar a adição no estoque");
    } else {
      _quantidade += val;
    }
  }

  @override
  int compareTo(other) {
    return nomeProduto.compareTo(other.nomeProduto);
  }

  void atualizarDados(ProdutoEstoque produto) {
    nomeProduto = produto.nomeProduto;
    descricao = produto.descricao;
    _quantidade = produto._quantidade;
    unidade = produto.unidade;
  }
}
