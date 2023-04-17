import 'dart:async';

import 'package:dio/dio.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';
import 'package:lanchonete/provider/conexao/dados_provider.dart';
import 'package:lanchonete/provider/conexao/dio_controller.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/provider/manipulador_erro.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/produtoEstoque/Models/estoque.dart';

class EstoqueApiProvider extends StreamProvider {
  // Atributo que irá afunilar todas as consultas
  static EstoqueApiProvider helper = EstoqueApiProvider._createInstance();
  // Construtor privado
  EstoqueApiProvider._createInstance()
      : super(DadosProvider.localProdutosEstoque + '/sse');

  Estoque? _estoque;

  bool get carregado {
    return _estoque != null && statusConexao == StatusConexao.conectado;
  }

  final _urlBaseEstoque = DadosProvider.localProdutosEstoque;
  final Dio _dio = DioController.instance.dioAreaRestrita;

  @override
  void mapFunction(List<Map> dados) {
    for (Map dado in dados) {
      if (dado['acao'] == "Removido") {
        _estoque!.removerProduto(dado['id']);
      } else {
        ProdutoEstoque produtoEstoque = ProdutoEstoque.fromMap(dado['data']);
        produtoEstoque.id = dado['id'];
        if (dado['acao'] == "Adicionado") {
          _estoque!.adicionarProduto(produtoEstoque);
        } else if (dado['acao'] == "Alterado") {
          _estoque!.atualizarProduto(produtoEstoque);
        }
      }
    }
    return; // notifica a alteração sem passar informações
  }

  @override
  void criarRepositorioDados() {
    _estoque = Estoque();
  }

  @override
  void limparRepositorioDados() {
    _estoque = null;
  }

  List<ProdutoEstoque> getProdutoEstoqueList() {
    return _estoque!.carregarProdutos();
  }

  ProdutoEstoque getProdutoEstoque(String produtoEstoqueId) {
    return _estoque!.carregarProduto(produtoEstoqueId);
  }

  Future<void> insertProdutoEstoque(ProdutoEstoque produtoEstoque) async {
    try {
      var dados = produtoEstoque.toMap();
      dados['idUsuario'] = uid;
      await _dio.post(_urlBaseEstoque, data: dados);
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> updateProdutoEstoque(ProdutoEstoque produtoEstoque) async {
    try {
      await _dio.put(
        _urlBaseEstoque + "/${produtoEstoque.id}",
        data: produtoEstoque.toMap(),
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> deleteProdutoEstoque(String produtoEstoqueId) async {
    try {
      await _dio.delete(_urlBaseEstoque + "/$produtoEstoqueId");
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }
}
