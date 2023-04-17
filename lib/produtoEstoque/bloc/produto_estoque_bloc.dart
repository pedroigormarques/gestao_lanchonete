import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/stream/controller/controlador_stream_api.dart';
import 'package:lanchonete/provider/stream_provider.dart';
import 'package:lanchonete/provider/estoque_provider.dart';
import 'package:lanchonete/stream/bloc/stream_bloc.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';

class ProdutoEstoqueBloc
    extends StreamBloc<ProdutoEstoqueEvent, ProdutoEstoqueState> {
  EstoqueApiProvider estoqueProvider = EstoqueApiProvider.helper;

  ProdutoEstoqueBloc()
      : super(EstoqueApiProvider.helper, CarregandoProdutosEstoque()) {
    on<CarregarProdutosEstoque>(_carregarProdutos);
    on<CarregarProdutoEstoque>(_carregarProduto);
    on<AdicionarAoEstoque>(_adicionarProduto);
    on<AtualizarProdutoDoEstoque>(_atualizarProduto);
    on<RemoverDoEstoque>(_removerProduto);
  }

  @override
  void notificarAtualizacao(
      NovaNotificacao event, Emitter<ProdutoEstoqueState> emit) {
    Notificacao notificacao = event.notificacao;
    debugPrint(
      notificacao.tipoNotificacao.toString() +
          ':e>' +
          notificacao.mensagem.toString(),
    );

    switch (notificacao.tipoNotificacao) {
      case TipoNotificacao.conectando:
        emit(CarregandoProdutosEstoque());
        break;
      case TipoNotificacao.erroConexao:
        debugPrint(notificacao.mensagem);
        try {
          emit(ErroCarregarProdutosEstoque());
        } catch (e) {
          debugPrint(e.toString());
        }
        break;
      case TipoNotificacao.novoDado:
        ProdutoEstoqueState state = this.state;
        if (state is ProdutoDoEstoqueCarregado) {
          add(CarregarProdutoEstoque(state.produto.id));
        } else if (state is ProdutosDoEstoqueCarregados ||
            state is CarregandoProdutosEstoque) {
          add(CarregarProdutosEstoque());
        }
        break;
    }
  }

  void _carregarProdutos(
      CarregarProdutosEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    //Só carrega se conexão bem sucedida.
    //Do contrário, a stream que controla o estado da página principal
    if (estoqueProvider.statusConexao == StatusConexao.conectado) {
      emit(
          ProdutosDoEstoqueCarregados(estoqueProvider.getProdutoEstoqueList()));
    }
  }

  void _carregarProduto(
      CarregarProdutoEstoque event, Emitter<ProdutoEstoqueState> emit) {
    emit(CarregandoProdutoEstoque());
    try {
      ProdutoEstoque produto =
          estoqueProvider.getProdutoEstoque(event.idProduto);
      emit(ProdutoDoEstoqueCarregado(produto));
    } catch (_) {
      emit(ErroCarregarProdutoEstoque());
    }
  }

  Future<void> _adicionarProduto(
      AdicionarAoEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    try {
      await estoqueProvider.insertProdutoEstoque(event.produto);
      emit(SucessoAoAdicionarProdutoEstoque());
    } on FormatException catch (erro) {
      emit(ErroAoAdicionararProdutoEstoque(erro.message));
    }
  }

  Future<void> _atualizarProduto(AtualizarProdutoDoEstoque event,
      Emitter<ProdutoEstoqueState> emit) async {
    try {
      await EstoqueApiProvider.helper
          .updateProdutoEstoque(event.produtoEstoque);
      emit(SucessoAoAtualizarProdutoEstoque());
    } on FormatException catch (erro) {
      emit(ErroAoAtualizarProdutoEstoque(erro.message));
    }
  }

  Future<void> _removerProduto(
      RemoverDoEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    final state = this.state;
    if (state is ProdutoDoEstoqueCarregado) {
      try {
        await estoqueProvider.deleteProdutoEstoque(event.idProduto);
        emit(SucessoAoRemoverProdutoEstoque());
      } on FormatException catch (erro) {
        emit(ErroAoRemoverProdutoEstoque(erro.message));
        //para conseguir atualizar o produto mesmo após a ocorrencia de um erro de remoção
        emit(ProdutoDoEstoqueCarregado(state.produto));
      }
    } else {
      emit(ErroAoRemoverProdutoEstoque(
          "Erro ao remover o produto! Caminho não estipulado"));
    }
  }
}
