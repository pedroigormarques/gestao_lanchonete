import 'package:dio/dio.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';
import 'package:lanchonete/provider/conexao/dados_provider.dart';
import 'package:lanchonete/provider/conexao/dio_controller.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/provider/manipulador_erro.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/cardapio/models/cardapio.dart';
import 'package:lanchonete/provider/estoque_provider.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';

class CardapioApiProvider extends StreamProvider {
  // Atributo que irá afunilar todas as consultas
  static CardapioApiProvider helper = CardapioApiProvider._createInstance();
  // Construtor privado
  CardapioApiProvider._createInstance()
      : super(DadosProvider.localProdutosCardapio + '/sse');

  Cardapio? _cardapio;
  bool get carregado {
    return _cardapio != null && statusConexao == StatusConexao.conectado;
  }

  final _urlBaseCardapio = DadosProvider.localProdutosCardapio;
  final Dio _dio = DioController.instance.dioAreaRestrita;

  @override
  bool precondicaoConluida() {
    return EstoqueApiProvider.helper.carregado;
  }

  @override
  String gerarMensagemErroPrecondicao() {
    return 'Cardapio não carregado devido ao estoque não estar carregado';
  }

  @override
  void criarRepositorioDados() {
    _cardapio = Cardapio();
  }

  @override
  void limparRepositorioDados() {
    _cardapio = null;
  }

  @override
  void mapFunction(List<Map> dados) {
    try {
      List<ProdutoEstoque> produtosEstoque =
          EstoqueApiProvider.helper.getProdutoEstoqueList();

      for (Map evento in dados) {
        if (evento['acao'] == "Removido") {
          _cardapio!.removerProduto(evento['id']);
        } else {
          ProdutoCardapio produtoCardapio =
              ProdutoCardapio.fromMap(evento['data'], produtosEstoque);
          produtoCardapio.id = evento['id'];
          if (evento['acao'] == "Adicionado") {
            _cardapio!.adicionarProduto(produtoCardapio);
          } else if (evento['acao'] == "Alterado") {
            _cardapio!.atualizarProduto(produtoCardapio);
          }
        }
      }
    } catch (e) {
      _cardapio!.adicionarProduto(ProdutoCardapio(
          'ERRO_CARREGAMENTO_NAO_CONCLUIDO',
          e.toString(),
          5,
          CATEGORIAS.bebidas,
          {},
          id: 'as'));
      rethrow;
    }

    return; // notifica a alteração sem passar informações
  }

  List<ProdutoCardapio> getCardapioList() {
    return _cardapio!.carregarProdutos();
  }

  ProdutoCardapio getProdutoCardapio(String produtoCardapioId) {
    return _cardapio!.carregarProduto(produtoCardapioId);
  }

  Future<void> insertProdutoCardapio(ProdutoCardapio produtoCardapio) async {
    try {
      var dados = produtoCardapio.toMap();
      dados['idUsuario'] = uid;
      await _dio.post(_urlBaseCardapio, data: dados);
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> updateProdutoCardapio(ProdutoCardapio produtoCardapioAntigo,
      ProdutoCardapio produtoCardapioAtualizado) async {
    try {
      await _dio.put(
        _urlBaseCardapio + "/${produtoCardapioAtualizado.id}",
        data: produtoCardapioAtualizado.toMap(),
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }

    /*CollectionReference meuCardapio = _instance.collection("cardapios").doc(_uid).collection("meu_cardapio");
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
    return 42;*/
  }

  Future<void> deleteProdutoCardapio(ProdutoCardapio produtoCardapio) async {
    try {
      await _dio.delete(_urlBaseCardapio + "/${produtoCardapio.id}");
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }
}
