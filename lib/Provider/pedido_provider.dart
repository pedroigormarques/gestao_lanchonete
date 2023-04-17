import 'package:dio/dio.dart';
import 'package:lanchonete/provider/conexao/dados_provider.dart';
import 'package:lanchonete/provider/conexao/dio_controller.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/provider/manipulador_erro.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/provider/cardapio_provider.dart';
import 'package:lanchonete/pedidos/models/lista_pedidos.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/pedidos/models/pedido_fechado.dart';
import 'package:lanchonete/pedidos/models/pedidos_fechados.dart';

class PedidosApiProvider extends StreamProvider {
  // Atributo que irá afunilar todas as consultas
  static PedidosApiProvider helper = PedidosApiProvider._createInstance();
  // Construtor privado
  PedidosApiProvider._createInstance()
      : super(DadosProvider.localPedidos + '/sse');

  final _urlBasePedidos = DadosProvider.localPedidos;
  final _urlBasePedidosFechados = DadosProvider.localPedidosFechados;
  final Dio _dio = DioController.instance.dioAreaRestrita;

  ListaPedidos? _pedidos;

  @override
  void mapFunction(List<Map> dados) {
    try {
      List<ProdutoCardapio> produtosCardapio =
          CardapioApiProvider.helper.getCardapioList();

      for (Map evento in dados) {
        if (evento['acao'] == "Removido") {
          _pedidos!.removerPedido(evento['id']);
        } else {
          Pedido pedido = Pedido.fromMap(evento['data'], produtosCardapio);
          pedido.id = evento['id'];
          if (evento['acao'] == "Adicionado") {
            _pedidos!.adicionarPedido(pedido);
          } else if (evento['acao'] == "Alterado") {
            _pedidos!.atualizarPedido(pedido);
          }
        }
      }
    } catch (e) {
      _pedidos!.adicionarPedido(Pedido(
        -2,
        {
          ProdutoCardapio('ERRO_CARREGAMENTO_NAO_CONCLUIDO', e.toString(), 5,
              CATEGORIAS.bebidas, {},
              id: 'as'): 1
        },
        id: 'as',
      ));
      rethrow;
    }

    return; // notifica a alteração sem passar informações
  }

  @override
  bool precondicaoConluida() {
    return CardapioApiProvider.helper.carregado;
  }

  @override
  String gerarMensagemErroPrecondicao() {
    return 'Pedidos não carregados devido ao cardapio não estar carregado';
  }

  @override
  void criarRepositorioDados() {
    _pedidos = ListaPedidos();
  }

  @override
  void limparRepositorioDados() {
    _pedidos = null;
  }

  List<Pedido> getPedidosList() {
    return _pedidos!.carregarListaPedidos();
  }

  Pedido getPedido(String pedidoId) {
    return _pedidos!.carregarPedido(pedidoId);
  }

  Future<void> insertPedido(Pedido pedido) async {
    try {
      await _dio.post(
        _urlBasePedidos,
        data: {'idUsuario': uid, 'mesa': pedido.mesa},
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> _updateItemPedido(
      String pedidoId, int novaQtd, String produtoId) async {
    try {
      await _dio.post(
        _urlBasePedidos + "/$pedidoId",
        data: {"novaQtd": novaQtd, "idProdutoCardapio": produtoId},
      );
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> updateAdicionarItemPedido(
      String pedidoId, Pedido pedido, String produtoAdicionadoId) async {
    try {
      ProdutoCardapio produto = pedido.produtosVendidos.keys
          .firstWhere((element) => element.id == produtoAdicionadoId);

      int novaqtd = pedido.produtosVendidos[produto]!;

      await _updateItemPedido(pedidoId, novaqtd, produtoAdicionadoId);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateRemoverItemPedido(
      String pedidoId, Pedido pedido, ProdutoCardapio produtoRemovido) async {
    //pedido?, produtoCardapio?
    try {
      await _updateItemPedido(pedidoId, 0, produtoRemovido.id);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateQuantidadeItemPedido(
      String pedidoId, Pedido pedido, String produtoAlteradoId) async {
    try {
      ProdutoCardapio produto = pedido.produtosVendidos.keys
          .firstWhere((element) => element.id == produtoAlteradoId);

      int novaqtd = pedido.produtosVendidos[produto]!;

      await _updateItemPedido(pedidoId, novaqtd, produtoAlteradoId);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deletePedido(Pedido pedido) async {
    try {
      await _dio.post(_urlBasePedidos + "/${pedido.id}/deletar");
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<void> fecharPedido(Pedido pedido) async {
    try {
      await _dio.post(_urlBasePedidos + "/${pedido.id}/fechar");
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }

  Future<ListaPedidosFechados> getPedidosFechadosList() async {
    try {
      ListaPedidosFechados listaPedidosFechados = ListaPedidosFechados();
      Response response = await _dio.get(_urlBasePedidosFechados);

      List dados = response.data;
      for (dynamic dado in dados) {
        PedidoFechado pedido = PedidoFechado.fromMap(dado);
        listaPedidosFechados.adicionarPedido(pedido);
      }
      return listaPedidosFechados;
    } catch (erro) {
      throw ManipuladorErro.gerarErro(erro);
    }
  }
}
