import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/produtoEstoque/Models/estoque.dart';

class EstoqueFirestoreServer {
  // Atributo que irá afunilar todas as consultas
  static EstoqueFirestoreServer helper = EstoqueFirestoreServer._createInstance();

  // Construtor privado
  EstoqueFirestoreServer._createInstance();

  String? _uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Estoque? _estoque;

  void limparDadosProdutosEstoque() {
    _estoque = null;
    _uid = null;
  }

  Stream<void> iniciarStreamProdutosEstoque(String uid) {
    _uid = uid;
    _estoque = Estoque();

    CollectionReference estoqueColection = _db.collection("estoques").doc(uid).collection("meu_estoque");
    return estoqueColection.snapshots().map((event) {
      for (DocumentChange docChange in event.docChanges) {
        ProdutoEstoque produtoEstoque = ProdutoEstoque.fromMap(docChange.doc.data());
        produtoEstoque.id = docChange.doc.id;

        switch (docChange.type.name) {
          case "added":
            _estoque!.adicionarProduto(produtoEstoque);
            break;
          case "removed":
            _estoque!.removerProduto(produtoEstoque.id);
            break;
          case "modified":
            _estoque!.atualizarProduto(produtoEstoque);
            break;
        }
      }
      return; // notifica a alteração sem passar informações 
    });
  }

  List<ProdutoEstoque> getProdutoEstoqueList() {
    return _estoque!.carregarProdutos();
  }

  ProdutoEstoque getProdutoEstoque(String produtoEstoqueId) {
    return _estoque!.carregarProduto(produtoEstoqueId);
  }

  Future<int> insertProdutoEstoque(ProdutoEstoque produtoEstoque) async {
    CollectionReference meuEstoque = _db.collection("estoques").doc(_uid).collection("meu_estoque");

    bool produtoExiste = (await meuEstoque.where('nomeProduto', isEqualTo: produtoEstoque.nomeProduto).get()).docs.isNotEmpty;
    if (produtoExiste) {
      throw const FormatException("Já existe um produto com esse nome cadastrado");
    } else {
      DocumentReference docRef = await meuEstoque.add(produtoEstoque.toMap());
      produtoEstoque.id = docRef.id;
    }
    return 42;
  }

  Future<int> updateProdutoEstoque(ProdutoEstoque produtoEstoque) async {
    _db.collection("estoques").doc(_uid).collection("meu_estoque").doc(produtoEstoque.id).update(produtoEstoque.toMap());

    return 42;
  }

  Future<int> deleteProdutoEstoque(produtoEstoqueId) async {
    DocumentReference produtoEstoqueDocument = _db.collection("estoques").doc(_uid).collection("meu_estoque").doc(produtoEstoqueId);

    bool produtoSendoUsado = await _getProdutoSendoUsado(produtoEstoqueId);

    if (produtoSendoUsado) {
      throw const FormatException("Produto está sendo utilizado por ao menos um produto do cardápio");
    } else {
      produtoEstoqueDocument.delete();
    }
    return 42;
  }

  Future<bool> _getProdutoSendoUsado(produtoEstoqueId) async {
    DocumentReference produtoEstoqueUtilizados =
        _db.collection("produtos_utilizados").doc(_uid).collection("produtos_estoque_utilizados").doc(produtoEstoqueId);

    QuerySnapshot querySnapshot = await produtoEstoqueUtilizados.collection("usado_em").limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
