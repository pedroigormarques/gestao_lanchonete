import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_event.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/Provider/cardapio_provider.dart';

class ProdutoCardapioBloc extends Bloc<ProdutoCardapioEvent, ProdutoCardapioState> {
  StreamSubscription? _listener;

  ProdutoCardapioBloc() : super(CarregandoProdutosCardapio()) {
    on<IniciarStreamProdutosCardapio>(_iniciarStream);
    on<PararStreamProdutosCardapio>(_pararStream);
    on<CarregarProdutosCardapio>(_carregarProdutos);
    on<CarregarProdutoCardapio>(_carregarProduto);
    on<AdicionarAoCardapio>(_adicionarProduto);
    on<AtualizarProdutoDoCardapio>(_atualizarProduto);
    on<RemoverDoCardapio>(_removerProduto);
  }

  void _iniciarStream(IniciarStreamProdutosCardapio event, Emitter<ProdutoCardapioState> emit) {
    _listener = CardapioFirestoreServer.helper.iniciarStreamProdutosCardapio(event.uid).listen((event) {
      ProdutoCardapioState atualState = state;
      if (atualState is ProdutoDoCardapioCarregado) {
        add(CarregarProdutoCardapio(atualState.produto.id));
      } else if (state is ProdutosDoCardapioCarregados) {
        add(CarregarProdutosCardapio());
      }
    });
  }

  void _pararStream(PararStreamProdutosCardapio event, Emitter<ProdutoCardapioState> emit) {
    _listener!.cancel();
    CardapioFirestoreServer.helper.limparDadosProdutosCardapio();
  }

  void _carregarProdutos(CarregarProdutosCardapio event, Emitter<ProdutoCardapioState> emit){
    emit(CarregandoProdutosCardapio());
    try {
      emit(ProdutosDoCardapioCarregados(CardapioFirestoreServer.helper.getCardapioList()));
    } catch (_) {
      emit(ErroCarregarProdutosCardapio());
    }
  }

  void _carregarProduto(CarregarProdutoCardapio event, Emitter<ProdutoCardapioState> emit){
    emit(CarregandoProdutoCardapio());
    try {
      ProdutoCardapio produto = CardapioFirestoreServer.helper.getProdutoCardapio(event.idProduto);
      emit(ProdutoDoCardapioCarregado(produto));
    } catch (_) {
      emit(ErroCarregarProdutoCardapio());
    }
  }

  Future<void> _adicionarProduto(AdicionarAoCardapio event, Emitter<ProdutoCardapioState> emit) async {
    try {
      await CardapioFirestoreServer.helper.insertProdutoCardapio(event.produto);
      emit(SucessoAoAdicionarProdutoCardapio());
    } on FormatException catch (erro) {
      emit(ErroAoAdicionarProdutoCardapio(erro.message));
    }
  }

  Future<void> _atualizarProduto(AtualizarProdutoDoCardapio event, Emitter<ProdutoCardapioState> emit) async {
    try {
      await CardapioFirestoreServer.helper.updateProdutoCardapio(event.produtoAntigo, event.produtoAtual);
      emit(SucessoAoAtualizarProdutoCardapio());
    } on FormatException catch (erro) {
      emit(ErroAoAtualizarProdutoCardapio(erro.message));
    }
  }

  Future<void> _removerProduto(RemoverDoCardapio event, Emitter<ProdutoCardapioState> emit) async {
    final state = this.state;
    if (state is ProdutoDoCardapioCarregado) {
      try {
        await CardapioFirestoreServer.helper.deleteProdutoCardapio(event.produto);
        emit(SucessoAoRemoverProdutoCardapio());
      } on FormatException catch (erro) {
        emit(ErroAoRemoverProdutoCardapio(erro.message));
        //para conseguir atualizar o produto mesmo após a ocorrencia de um erro de remoção
        emit(ProdutoDoCardapioCarregado(state.produto));
      }
    } else {
      emit(ErroAoRemoverProdutoCardapio("Erro ao remover o produto! Caminho não estipulado"));
    }
  }
}
