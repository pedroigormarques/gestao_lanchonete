import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/cardapio/models/cardapio.dart';
import 'package:lanchonete/Provider/estoque_provider.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

class CardapioFirestoreServer {
  // Atributo que irá afunilar todas as consultas
  static CardapioFirestoreServer helper = CardapioFirestoreServer._createInstance();

  // Construtor privado
  CardapioFirestoreServer._createInstance();

  String? _uid;

  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  Cardapio? _cardapio;

  void limparDadosProdutosCardapio() {
    _cardapio = null;
    _uid = null;
  }

  Stream<void> iniciarStreamProdutosCardapio(String uid) {
    _uid = uid;
    _cardapio = Cardapio();

    CollectionReference cardapioColection = _instance.collection("cardapios").doc(_uid).collection("meu_cardapio");
    return cardapioColection.snapshots().map((event) {
      List<ProdutoEstoque> produtosEstoque = EstoqueFirestoreServer.helper.getProdutoEstoqueList();
      for (DocumentChange docChange in event.docChanges) {
        ProdutoCardapio produtoCardapio = ProdutoCardapio.fromMap(docChange.doc.data(), produtosEstoque);
        produtoCardapio.id = docChange.doc.id;

        switch (docChange.type.name) {
          case "added":
            _cardapio!.adicionarProduto(produtoCardapio);
            break;
          case "removed":
            _cardapio!.removerProduto(produtoCardapio.id);
            break;
          case "modified":
            _cardapio!.atualizarProduto(produtoCardapio);
            break;
        }
      }
      return; // notifica a alteração sem passar informações
    });
  }

  List<ProdutoCardapio> getCardapioList() {
    return _cardapio!.carregarProdutos();
  }

  ProdutoCardapio getProdutoCardapio(String produtoCardapioId) {
    return _cardapio!.carregarProduto(produtoCardapioId);
  }

  Future<int> insertProdutoCardapio(ProdutoCardapio produtoCardapio) async {
    CollectionReference meuCardapio = _instance.collection("cardapios").doc(_uid).collection("meu_cardapio");
    CollectionReference produtosEstoqueUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_estoque_utilizados");

    bool produtoExiste = (await meuCardapio.where('nomeProduto', isEqualTo: produtoCardapio.nomeProduto).get()).docs.isNotEmpty;
    if (produtoExiste) {
      throw const FormatException("Já existe um produto com esse nome cadastrado");
    } else {
      DocumentReference newDocRef = meuCardapio.doc();
      WriteBatch batch = _instance.batch();

      batch.set(newDocRef, produtoCardapio.toMap());

      produtoCardapio.composicao.forEach((produto, qtd) {
        batch.set(produtosEstoqueUtilizados.doc(produto.id).collection("usado_em").doc(newDocRef.id), {newDocRef.id: true});
      });

      batch.commit();

      produtoCardapio.id = newDocRef.id;
    }
    return 42;
  }

  Future<int> updateProdutoCardapio(ProdutoCardapio produtoCardapioAntigo, ProdutoCardapio produtoCardapioAtualizado) async {
    CollectionReference meuCardapio = _instance.collection("cardapios").doc(_uid).collection("meu_cardapio");
    CollectionReference produtosEstoqueUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_estoque_utilizados");

    bool atualizacaoPermitida;
    if (produtoCardapioAntigo.nomeProduto == produtoCardapioAtualizado.nomeProduto) {
      atualizacaoPermitida = true;
    } else {
      atualizacaoPermitida =
          (await meuCardapio.where('nomeProduto', isEqualTo: produtoCardapioAtualizado.nomeProduto).limit(1).get()).docs.isEmpty;
    }

    if (!atualizacaoPermitida) {
      throw const FormatException("Não é possível atualizar pois já existe um produto com esse nome");
    } else {
      WriteBatch batch = _instance.batch();

      batch.update(meuCardapio.doc(produtoCardapioAntigo.id), produtoCardapioAtualizado.toMap()); //atualiza o produto

      List<String> idsProdutosAntigos = produtoCardapioAntigo.composicao.keys.map((e) => e.id).toList();
      List<String> idsProdutosAtuais = produtoCardapioAtualizado.composicao.keys.map((e) => e.id).toList();

      //remove da lista os produtos do estoque não mais usados
      for (String idprodutoAntigo in idsProdutosAntigos) {
        if (!idsProdutosAtuais.contains(idprodutoAntigo)) {
          batch.delete(produtosEstoqueUtilizados.doc(idprodutoAntigo).collection("usado_em").doc(produtoCardapioAntigo.id));
        }
      }

      //adiciona na lista os produtos do estoque que passarão a ser usados
      for (String idprodutoAtual in idsProdutosAtuais) {
        if (!idsProdutosAntigos.contains(idprodutoAtual)) {
          batch.set(produtosEstoqueUtilizados.doc(idprodutoAtual).collection("usado_em").doc(produtoCardapioAntigo.id),
              {produtoCardapioAntigo.id: true});
        }
      }

      batch.commit();
    }
    return 42;
  }

  Future<int> deleteProdutoCardapio(ProdutoCardapio produtoCardapio) async {
    CollectionReference meuCardapio = _instance.collection("cardapios").doc(_uid).collection("meu_cardapio");
    CollectionReference produtosEstoqueUtilizados =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_estoque_utilizados");

    bool produtoSendoUsado = await _getProdutoSendoUsado(produtoCardapio.id);

    if (produtoSendoUsado) {
      throw const FormatException("Produto está sendo utilizado por ao menos um pedido");
    } else {
      WriteBatch batch = _instance.batch();

      batch.delete(meuCardapio.doc(produtoCardapio.id)); //remove o produto

      for (ProdutoEstoque produto in produtoCardapio.composicao.keys) {
        //remove da lista os produtos do estoque usados
        batch.delete(produtosEstoqueUtilizados.doc(produto.id).collection("usado_em").doc(produtoCardapio.id));
      }

      batch.commit();
    }

    return 42;
  }

  Future<bool> _getProdutoSendoUsado(produtoCardapioId) async {
    DocumentReference produtoCardapioUtilizado =
        _instance.collection("produtos_utilizados").doc(_uid).collection("produtos_cardapio_utilizados").doc(produtoCardapioId);

    QuerySnapshot querySnapshot = await produtoCardapioUtilizado.collection("usado_em").limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
