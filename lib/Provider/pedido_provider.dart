import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/Provider/cardapio_provider.dart';
import 'package:lanchonete/pedidos/models/lista_pedidos.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/pedidos/models/pedido_fechado.dart';
import 'package:lanchonete/pedidos/models/pedidos_fechados.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

class PedidosFirestoreServer {
  // Atributo que irá afunilar todas as consultas
  static PedidosFirestoreServer helper = PedidosFirestoreServer._createInstance();

  // Construtor privado
  PedidosFirestoreServer._createInstance();

  String? _uid;

  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  ListaPedidos? _pedidos;

  void limparDadosProdutosEstoque() {
    _pedidos = null;
    _uid = null;
  }

  Stream<void> iniciarStreamPedidos(String uid) {
    _uid = uid;
    _pedidos = ListaPedidos();

    CollectionReference pedidosCollection = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    return pedidosCollection.snapshots().map((event) {
      List<ProdutoCardapio> produtosCardapio = CardapioFirestoreServer.helper.getCardapioList();
      for (DocumentChange docChange in event.docChanges) {
        Pedido pedido = Pedido.fromMap(docChange.doc.data(), produtosCardapio);
        pedido.id = docChange.doc.id;

        switch (docChange.type.name) {
          case "added":
            _pedidos!.adicionarPedido(pedido);
            break;
          case "removed":
            _pedidos!.removerPedido(pedido.id);
            break;
          case "modified":
            _pedidos!.atualizarPedido(pedido);
            break;
        }
      }
      return; // notifica a alteração sem passar informações
    });
  }

  List<Pedido> getPedidosList() {
    return _pedidos!.carregarListaPedidos();
  }

  Pedido getPedido(String pedidoId) {
    return _pedidos!.carregarPedido(pedidoId);
  }

  Future<int> insertPedido(Pedido pedido) async {
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");

    bool pedidoAberto = (await meusPedidos.where('mesa', isEqualTo: pedido.mesa).get()).docs.isNotEmpty;
    if (pedidoAberto) {
      throw const FormatException("Já existe um pedido aberto para essa mesa");
    } else {
      DocumentReference docRef = await meusPedidos.add(pedido.toMap());
      pedido.id = docRef.id;
    }
    return 42;
  }

  Future<int> updateAdicionarItemPedido(String pedidoId, Pedido pedido, String produtoAdicionadoId) async {
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    CollectionReference meuEstoque = _instance.collection("estoques").doc(_uid).collection("meu_estoque");
    CollectionReference produtosCardapioUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_cardapio_utilizados");

    WriteBatch batch = _instance.batch();

    ProdutoCardapio produtoCardapioAtualizado =
        pedido.produtosVendidos.keys.firstWhere((element) => element.id == produtoAdicionadoId);

    List<ProdutoEstoque> produtosAtualizados = produtoCardapioAtualizado.composicao.keys.toList();

    //remove as repetições
    produtosAtualizados = produtosAtualizados.toSet().toList();

    batch.update(meusPedidos.doc(pedidoId), pedido.toMap()); //atualiza o pedido

    // adiciona o produto na lista de produtos do cardapio usados
    batch.set(produtosCardapioUtilizados.doc(produtoAdicionadoId).collection("usado_em").doc(pedidoId), {pedidoId: true});

    for (ProdutoEstoque produto in produtosAtualizados) {
      batch.update(meuEstoque.doc(produto.id), {"quantidade": produto.quantidade}); //atualiza os produtos do estoque
    }

    batch.commit();

    return 42;
  }

  Future<int> updateRemoverItemPedido(String pedidoId, Pedido pedido, ProdutoCardapio produtoRemovido) async {
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    CollectionReference meuEstoque = _instance.collection("estoques").doc(_uid).collection("meu_estoque");
    CollectionReference produtosCardapioUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_cardapio_utilizados");

    WriteBatch batch = _instance.batch();

    List<ProdutoEstoque> produtosAtualizados = produtoRemovido.composicao.keys.toList();

    //remove as repetições
    produtosAtualizados = produtosAtualizados.toSet().toList();

    batch.update(meusPedidos.doc(pedidoId), pedido.toMap()); //atualiza o pedido

    // remove o produto da lista de produtos do cardapio usados
    batch.delete(produtosCardapioUtilizados.doc(produtoRemovido.id).collection("usado_em").doc(pedidoId));

    for (ProdutoEstoque produto in produtosAtualizados) {
      batch.update(meuEstoque.doc(produto.id), {"quantidade": produto.quantidade}); //atualiza os produtos do estoque
    }

    batch.commit();

    return 42;
  }

  Future<int> updateQuantidadeItemPedido(String pedidoId, Pedido pedido, String produtoAlteradoId) async {
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    CollectionReference meuEstoque = _instance.collection("estoques").doc(_uid).collection("meu_estoque");

    WriteBatch batch = _instance.batch();

    ProdutoCardapio produtoCardapioAlterado = pedido.produtosVendidos.keys.firstWhere((element) => element.id == produtoAlteradoId);

    List<ProdutoEstoque> produtosAtualizados = produtoCardapioAlterado.composicao.keys.toList();

    //remove as repetições
    produtosAtualizados = produtosAtualizados.toSet().toList();

    batch.update(meusPedidos.doc(pedidoId), pedido.toMap()); //atualiza o pedido

    for (ProdutoEstoque produto in produtosAtualizados) {
      batch.update(meuEstoque.doc(produto.id), {"quantidade": produto.quantidade}); //atualiza os produtos do estoque
    }

    batch.commit();

    return 42;
  }

  Future<int> deletePedido(Pedido pedido) async {
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    CollectionReference meuEstoque = _instance.collection("estoques").doc(_uid).collection("meu_estoque");
    CollectionReference produtosCardapioUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_cardapio_utilizados");

    WriteBatch batch = _instance.batch();

    List<ProdutoEstoque> produtosAtualizados = [];

    while (pedido.produtosVendidos.isNotEmpty) {
      ProdutoCardapio produto = pedido.produtosVendidos.keys.first;

      // remove a lista de uso de items no pedido
      batch.delete(produtosCardapioUtilizados.doc(produto.id).collection("usado_em").doc(pedido.id));

      produtosAtualizados.addAll(produto.composicao.keys);
      pedido.removerProduto(produto);
    }

    //remove as repetições
    produtosAtualizados = produtosAtualizados.toSet().toList();

    batch.delete(meusPedidos.doc(pedido.id)); // remove o pedido

    for (ProdutoEstoque produto in produtosAtualizados) {
      batch.update(meuEstoque.doc(produto.id), {"quantidade": produto.quantidade}); //atualiza os produtos do estoque corretamente
    }

    batch.commit();

    return 42;
  }

  Future<int> fecharPedido(Pedido pedido) async {
    CollectionReference meusPedidosFechados = _instance.collection("pedidos_fechados").doc(_uid).collection("meus_pedidos_fechados");
    CollectionReference meusPedidos = _instance.collection("pedidos").doc(_uid).collection("meus_pedidos");
    CollectionReference produtosCardapioUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_cardapio_utilizados");

    DocumentReference newDocRef = meusPedidosFechados.doc();
    WriteBatch batch = _instance.batch();

    PedidoFechado pedidoFechado = PedidoFechado(pedido);

    //adiciona o pedido fechado
    batch.set(newDocRef, pedidoFechado.toMap());

    batch.delete(meusPedidos.doc(pedido.id)); // remove o pedido

    // remove os produtos da lista de produtos do cardapio usados
    for (var produto in pedido.produtosVendidos.keys) {
      batch.delete(produtosCardapioUtilizados.doc(produto.id).collection("usado_em").doc(pedido.id));
    }

    batch.commit();

    return 42;
  }

  Future<ListaPedidosFechados> getPedidosFechadosList() async {
    ListaPedidosFechados listaPedidosFechados = ListaPedidosFechados();

    QuerySnapshot querySnapshot = await _instance.collection("pedidos_fechados").doc(_uid).collection("meus_pedidos_fechados").get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        PedidoFechado pedido = PedidoFechado.fromMap(doc.data());
        listaPedidosFechados.adicionarPedido(pedido);
      }
    }
    return listaPedidosFechados;
  }
}
