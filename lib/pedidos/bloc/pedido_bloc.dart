import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_state.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/provider/pedido_provider.dart';
import 'package:lanchonete/stream/bloc/stream_bloc.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';

class PedidoBloc extends StreamBloc<PedidoEvent, PedidoState> {
  final PedidosApiProvider _pedidoProvider = PedidosApiProvider.helper;
  PedidoBloc() : super(PedidosApiProvider.helper, CarregandoPedidos()) {
    on<CarregarListaPedidos>(_carregarListaPedidos);
    on<CarregarPedido>(_carregarPedido);
    on<AdicionarPedido>(_adicionarPedido);
    on<RemoverPedido>(_removerPedido);
    on<FecharPedido>(_fecharPedido);
    on<AdicionarItemPedido>(_adicionarItemPedido);

    on<RemoverItemPedido>(_removerItemPedido);
    on<AdicionarQuantidadeItemPedido>(_adicionarQuantidadeItemPedido);
    on<RemoverQuantidadeItemPedido>(_removerQuantidadeItemPedido);
  }

  @override
  void notificarAtualizacao(NovaNotificacao event, Emitter<PedidoState> emit) {
    Notificacao notificacao = event.notificacao;
    switch (notificacao.tipoNotificacao) {
      case TipoNotificacao.conectando:
        emit(CarregandoPedidos());
        break;
      case TipoNotificacao.erroConexao:
        emit(ErroCarregarPedidos());
        break;
      case TipoNotificacao.novoDado:
        PedidoState state = this.state;
        if (state is PedidoCarregado) {
          add(CarregarPedido(state.pedido.id));
        } else if (state is PedidosCarregados || state is CarregandoPedidos) {
          add(CarregarListaPedidos());
        }
        break;
    }
  }

  void _carregarListaPedidos(
      CarregarListaPedidos event, Emitter<PedidoState> emit) {
    //Só carrega se conexão bem sucedida.
    //Do contrário, a stream que controla o estado da página principal
    if (_pedidoProvider.statusConexao == StatusConexao.conectado) {
      emit(PedidosCarregados(_pedidoProvider.getPedidosList()));
    }
  }

  void _carregarPedido(CarregarPedido event, Emitter<PedidoState> emit) {
    emit(CarregandoPedido());
    try {
      Pedido pedido = _pedidoProvider.getPedido(event.pedidoId);
      emit(PedidoCarregado(pedido));
    } catch (_) {
      emit(ErroCarregarPedido());
    }
  }

  Future<void> _adicionarPedido(
      AdicionarPedido event, Emitter<PedidoState> emit) async {
    var state = (this.state as PedidosCarregados);
    try {
      await _pedidoProvider.insertPedido(event.pedido);
      emit(SucessoAoAdicionarPedido("Pedido adicionado na lista com sucesso"));
    } on FormatException catch (erro) {
      emit(ErroAoAdicionarPedido(erro.message));
    } finally {
      // emite até o listener atualizar com a alteração
      emit(PedidosCarregados(state.listaPedidos));
    }
  }

  Future<void> _adicionarItemPedido(
      AdicionarItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux =
            state.pedido; //--------------------------------------------------
        aux.adicionarProduto(event.produtoCardapio);
        await _pedidoProvider.updateAdicionarItemPedido(
            event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAdicionarItemPedido(
            "Item adicionado no pedido com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAdicionarItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerItemPedido(
      RemoverItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux =
            state.pedido; //--------------------------------------------------
        aux.removerProduto(event.produtoCardapio);
        await _pedidoProvider.updateRemoverItemPedido(
            event.pedidoId, aux, event.produtoCardapio);

        emit(SucessoAoRemoverItemPedido("Item removido do pedido com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoRemoverItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _adicionarQuantidadeItemPedido(
      AdicionarQuantidadeItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux =
            state.pedido; //--------------------------------------------------
        aux.adicionarQuantidadeItem(event.produtoCardapio, event.quantidade);
        await _pedidoProvider.updateQuantidadeItemPedido(
            event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAlterarQuantidadeItemPedido(
            "Quantidade atualizada com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAlterarQuantidadeItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerQuantidadeItemPedido(
      RemoverQuantidadeItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux =
            state.pedido; //--------------------------------------------------
        aux.removerQuantidadeItem(event.produtoCardapio, event.quantidade);
        await _pedidoProvider.updateQuantidadeItemPedido(
            event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAlterarQuantidadeItemPedido(
            "Quantidade atualizada com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAlterarQuantidadeItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerPedido(
      RemoverPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        await _pedidoProvider.deletePedido(event.pedido);
        emit(SucessoAoRemoverPedido("Pedido cancelado com sucesso"));
      } on FormatException catch (erro) {
        emit(ErroAoRemoverPedido(erro.message));
        //para conseguir modificar o pedido mesmo após a ocorrencia de um erro de remoção
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _fecharPedido(
      FecharPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        if (event.pedido.produtosVendidos.isEmpty) {
          throw const FormatException(
              "Adicione algum produto ou exclua o pedido");
        }
        await _pedidoProvider.fecharPedido(event.pedido);
        emit(SucessoAoFecharPedido("Pedido fechado com sucesso"));
      } on FormatException catch (erro) {
        emit(ErroAoFecharPedido(erro.message));
        //para conseguir modificar o pedido mesmo após a ocorrencia de um erro de fechamento
        emit(PedidoCarregado(state.pedido));
      }
    } else {
      emit(ErroAoFecharPedido(
          "Erro ao fechar o pedido! Caminho não estipulado"));
    }
  }
}
