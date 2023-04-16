import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_state.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/Provider/pedido_provider.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  StreamSubscription? _listener;
  PedidoBloc() : super(CarregandoPedidos()) {
    on<IniciarStreamPedidos>(_iniciarStream);
    on<PararStreamPedidos>(_pararStream);

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

  void _iniciarStream(IniciarStreamPedidos event, Emitter<PedidoState> emit) {
    _listener = PedidosFirestoreServer.helper.iniciarStreamPedidos(event.uid).listen((event) {
      PedidoState atualState = state;
      if (atualState is PedidoCarregado) {
        add(CarregarPedido(atualState.pedido.id));
      } else if (state is PedidosCarregados) {
        add(CarregarListaPedidos());
      }
    });
  }

  void _pararStream(PararStreamPedidos event, Emitter<PedidoState> emit) {
    _listener!.cancel();
    PedidosFirestoreServer.helper.limparDadosProdutosEstoque();
  }

  void _carregarListaPedidos(CarregarListaPedidos event, Emitter<PedidoState> emit) {
    emit(CarregandoPedidos());
    try {
      emit(PedidosCarregados(PedidosFirestoreServer.helper.getPedidosList()));
    } catch (_) {
      emit(ErroCarregarPedidos());
    }
  }

  void _carregarPedido(CarregarPedido event, Emitter<PedidoState> emit) {
    emit(CarregandoPedido());
    try {
      Pedido pedido = PedidosFirestoreServer.helper.getPedido(event.pedidoId);
      emit(PedidoCarregado(pedido));
    } catch (_) {
      emit(ErroCarregarPedido());
    }
  }

  Future<void> _adicionarPedido(AdicionarPedido event, Emitter<PedidoState> emit) async {
    var state = (this.state as PedidosCarregados);
    try {
      await PedidosFirestoreServer.helper.insertPedido(event.pedido);
      emit(SucessoAoAdicionarPedido("Pedido adicionado na lista com sucesso"));
    } on FormatException catch (erro) {
      emit(ErroAoAdicionarPedido(erro.message));
    } finally {
      // emite até o listener atualizar com a alteração
      emit(PedidosCarregados(state.listaPedidos));
    }
  }

  Future<void> _adicionarItemPedido(AdicionarItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux = state.pedido; //--------------------------------------------------
        aux.adicionarProduto(event.produtoCardapio);
        await PedidosFirestoreServer.helper.updateAdicionarItemPedido(event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAdicionarItemPedido("Item adicionado no pedido com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAdicionarItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerItemPedido(RemoverItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux = state.pedido;  //--------------------------------------------------
        aux.removerProduto(event.produtoCardapio);
        await PedidosFirestoreServer.helper.updateRemoverItemPedido(event.pedidoId, aux, event.produtoCardapio);

        emit(SucessoAoRemoverItemPedido("Item removido do pedido com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoRemoverItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _adicionarQuantidadeItemPedido(AdicionarQuantidadeItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux = state.pedido;  //--------------------------------------------------
        aux.adicionarQuantidadeItem(event.produtoCardapio, event.quantidade);
        await PedidosFirestoreServer.helper.updateQuantidadeItemPedido(event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAlterarQuantidadeItemPedido("Quantidade atualizada com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAlterarQuantidadeItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerQuantidadeItemPedido(RemoverQuantidadeItemPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        Pedido aux = state.pedido;  //--------------------------------------------------
        aux.removerQuantidadeItem(event.produtoCardapio, event.quantidade);
        await PedidosFirestoreServer.helper.updateQuantidadeItemPedido(event.pedidoId, aux, event.produtoCardapio.id);

        emit(SucessoAoAlterarQuantidadeItemPedido("Quantidade atualizada com sucesso"));
        emit(PedidoCarregado(aux));
      } on FormatException catch (erro) {
        emit(ErroAoAlterarQuantidadeItemPedido(erro.message));
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  Future<void> _removerPedido(RemoverPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        await PedidosFirestoreServer.helper.deletePedido(event.pedido);
        emit(SucessoAoRemoverPedido("Pedido cancelado com sucesso"));
      } on FormatException catch (erro) {
        emit(ErroAoRemoverPedido(erro.message));
        //para conseguir modificar o pedido mesmo após a ocorrencia de um erro de remoção
        emit(PedidoCarregado(state.pedido));
      }
    }
  }

  //para exemplo fará a mesma coisa que o remover pedido
  Future<void> _fecharPedido(FecharPedido event, Emitter<PedidoState> emit) async {
    final state = this.state;
    if (state is PedidoCarregado) {
      try {
        if (event.pedido.produtosVendidos.isEmpty) {
          throw const FormatException("Adicione algum produto ou exclua o pedido");
        }
        await PedidosFirestoreServer.helper.fecharPedido(event.pedido);
        emit(SucessoAoFecharPedido("Pedido fechado com sucesso"));
      } on FormatException catch (erro) {
        emit(ErroAoFecharPedido(erro.message));
        //para conseguir modificar o pedido mesmo após a ocorrencia de um erro de fechamento
        emit(PedidoCarregado(state.pedido));
      }
    } else {
      emit(ErroAoFecharPedido("Erro ao fechar o pedido! Caminho não estipulado"));
    }
  }
}
