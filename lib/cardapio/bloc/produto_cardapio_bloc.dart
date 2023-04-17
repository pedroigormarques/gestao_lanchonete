import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_event.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/provider/cardapio_provider.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/stream/bloc/stream_bloc.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';

class ProdutoCardapioBloc
    extends StreamBloc<ProdutoCardapioEvent, ProdutoCardapioState> {
  final CardapioApiProvider _cardapioProvider = CardapioApiProvider.helper;

  ProdutoCardapioBloc()
      : super(CardapioApiProvider.helper, CarregandoProdutosCardapio()) {
    on<CarregarProdutosCardapio>(_carregarProdutos);
    on<CarregarProdutoCardapio>(_carregarProduto);
    on<AdicionarAoCardapio>(_adicionarProduto);
    on<AtualizarProdutoDoCardapio>(_atualizarProduto);
    on<RemoverDoCardapio>(_removerProduto);
  }

  @override
  void notificarAtualizacao(
      NovaNotificacao event, Emitter<ProdutoCardapioState> emit) {
    Notificacao notificacao = event.notificacao;
    switch (notificacao.tipoNotificacao) {
      case TipoNotificacao.conectando:
        emit(CarregandoProdutosCardapio());
        break;
      case TipoNotificacao.erroConexao:
        emit(ErroCarregarProdutosCardapio());
        break;
      case TipoNotificacao.novoDado:
        ProdutoCardapioState state = this.state;
        if (state is ProdutoDoCardapioCarregado) {
          add(CarregarProdutoCardapio(state.produto.id));
        } else if (state is ProdutosDoCardapioCarregados ||
            state is CarregandoProdutosCardapio) {
          add(CarregarProdutosCardapio());
        }
        break;
    }
  }

  void _carregarProdutos(
      CarregarProdutosCardapio event, Emitter<ProdutoCardapioState> emit) {
    //Só carrega se conexão bem sucedida.
    //Do contrário, a stream que controla o estado da página principal
    if (_cardapioProvider.statusConexao == StatusConexao.conectado) {
      emit(ProdutosDoCardapioCarregados(_cardapioProvider.getCardapioList()));
    }
  }

  void _carregarProduto(
      CarregarProdutoCardapio event, Emitter<ProdutoCardapioState> emit) {
    emit(CarregandoProdutoCardapio());
    try {
      ProdutoCardapio produto =
          _cardapioProvider.getProdutoCardapio(event.idProduto);
      emit(ProdutoDoCardapioCarregado(produto));
    } catch (_) {
      emit(ErroCarregarProdutoCardapio());
    }
  }

  Future<void> _adicionarProduto(
      AdicionarAoCardapio event, Emitter<ProdutoCardapioState> emit) async {
    try {
      await _cardapioProvider.insertProdutoCardapio(event.produto);
      emit(SucessoAoAdicionarProdutoCardapio());
    } on FormatException catch (erro) {
      emit(ErroAoAdicionarProdutoCardapio(erro.message));
    }
  }

  Future<void> _atualizarProduto(AtualizarProdutoDoCardapio event,
      Emitter<ProdutoCardapioState> emit) async {
    try {
      await _cardapioProvider.updateProdutoCardapio(
          event.produtoAntigo, event.produtoAtual);
      emit(SucessoAoAtualizarProdutoCardapio());
    } on FormatException catch (erro) {
      emit(ErroAoAtualizarProdutoCardapio(erro.message));
    }
  }

  Future<void> _removerProduto(
      RemoverDoCardapio event, Emitter<ProdutoCardapioState> emit) async {
    final state = this.state;
    if (state is ProdutoDoCardapioCarregado) {
      try {
        await _cardapioProvider.deleteProdutoCardapio(event.produto);
        emit(SucessoAoRemoverProdutoCardapio());
      } on FormatException catch (erro) {
        emit(ErroAoRemoverProdutoCardapio(erro.message));
        //para conseguir atualizar o produto mesmo após a ocorrencia de um erro de remoção
        emit(ProdutoDoCardapioCarregado(state.produto));
      }
    } else {
      emit(ErroAoRemoverProdutoCardapio(
          "Erro ao remover o produto! Caminho não estipulado"));
    }
  }
}
