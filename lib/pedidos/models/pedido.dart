import 'package:lanchonete/cardapio/models/produto_cardapio.dart';

class Pedido implements Comparable<Pedido> {
  late String id;

  late int mesa;
  Map<ProdutoCardapio, int> produtosVendidos = {};
  double _valorConta = 0.0;

  late final DateTime horaAbertura;

  Pedido(this.mesa, this.produtosVendidos, {String? id}) {
    horaAbertura = DateTime.now();
    if (produtosVendidos.isNotEmpty) {
      produtosVendidos.forEach((key, value) {
        _valorConta += key.preco * value;
      });
    }
    if (id != null) {
      this.id = id;
    }
  }

  Pedido.fromMap(map, List<ProdutoCardapio> produtosCardapio) {
    mesa = map["mesa"];
    _valorConta = map["valorConta"];
    horaAbertura = DateTime.parse(map["horaAbertura"]);

    if (map["produtosVendidos"] != null) {
      (map["produtosVendidos"] as Map).forEach((key, value) {
        produtosVendidos[produtosCardapio.firstWhere((element) => element.id == key)] = value;
      });
    }
  }

  toMap() {
    Map<String, dynamic> map = {};
    map["mesa"] = mesa;
    map["valorConta"] = valorConta;
    map["horaAbertura"] = horaAbertura.toString();

    map["produtosVendidos"] =
        produtosVendidos.map((produtoCardapio, quantidade) => MapEntry<String, int>(produtoCardapio.id, quantidade));
    return map;
  }

  adicionarQuantidadeItem(ProdutoCardapio produto, int quantidade) {
    if (produto.visualizarQuantidade() < quantidade) {
      throw const FormatException("Quantidade insuficiente");
    } else {
      produto.removerQuantidade(quantidade);
      produtosVendidos[produto] = produtosVendidos[produto]! + quantidade;
      _valorConta += produto.preco * quantidade;
    }
  }

  removerQuantidadeItem(ProdutoCardapio produto, int quantidade) {
    if (produtosVendidos[produto]! < quantidade) {
      throw const FormatException("Quantidade maior que o consumo");
    } else {
      produto.retornarQuantidade(quantidade);
      produtosVendidos[produto] = produtosVendidos[produto]! - quantidade;
      _valorConta -= produto.preco * quantidade;
    }
  }

  void adicionarProduto(ProdutoCardapio produto) {
    if (produto.visualizarQuantidade() == 0) {
      throw const FormatException("Quantidade insuficiente para ser adicionado ao pedido");
    }

    if (produtosVendidos.keys.contains(produto)) {
      throw const FormatException("Produto já adicionado na lista de itens");
    } else {
      produtosVendidos[produto] = 0;
      adicionarQuantidadeItem(produto, 1);
    }
  }

  void removerProduto(ProdutoCardapio produto) {
    if (!produtosVendidos.keys.contains(produto)) {
      throw const FormatException("Produto não se encontra na lista de itens");
    } else {
      removerQuantidadeItem(produto, produtosVendidos[produto]!);
      produtosVendidos.remove(produto);
    }
  }

  double get valorConta {
    return double.parse(_valorConta.toStringAsFixed(2));
  }

  @override
  int compareTo(other) {
    return mesa.compareTo(other.mesa);
  }

  void atualizarDados(Pedido pedido) {
    produtosVendidos = pedido.produtosVendidos;
    _valorConta = pedido._valorConta;
  }
}
