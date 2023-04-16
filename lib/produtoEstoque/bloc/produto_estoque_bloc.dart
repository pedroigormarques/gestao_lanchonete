import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/Provider/estoque_provider.dart';

class ProdutoEstoqueBloc extends Bloc<ProdutoEstoqueEvent, ProdutoEstoqueState> {
  StreamSubscription? _listener;

  ProdutoEstoqueBloc() : super(CarregandoProdutosEstoque()) {
    on<IniciarStreamProdutosEstoque>(_iniciarStream);
    on<PararStreamProdutosEstoque>(_pararStream);
    on<CarregarProdutosEstoque>(_carregarProdutos);
    on<CarregarProdutoEstoque>(_carregarProduto);
    on<AdicionarAoEstoque>(_adicionarProduto);
    on<AtualizarProdutoDoEstoque>(_atualizarProduto);
    on<RemoverDoEstoque>(_removerProduto);
  }

  void _iniciarStream(IniciarStreamProdutosEstoque event, Emitter<ProdutoEstoqueState> emit){
    _listener = EstoqueFirestoreServer.helper.iniciarStreamProdutosEstoque(event.uid).listen((event) {
      ProdutoEstoqueState atualState = state;
      if(atualState is ProdutoDoEstoqueCarregado){        
        add(CarregarProdutoEstoque(atualState.produto.id));
      }else if(state is ProdutosDoEstoqueCarregados){
        add(CarregarProdutosEstoque());
      }
    });
  }
  void _pararStream(PararStreamProdutosEstoque event, Emitter<ProdutoEstoqueState> emit){
    _listener!.cancel();
    EstoqueFirestoreServer.helper.limparDadosProdutosEstoque();
  }

  void _carregarProdutos(CarregarProdutosEstoque event, Emitter<ProdutoEstoqueState> emit) {
    emit(CarregandoProdutosEstoque());
    try {
      emit(ProdutosDoEstoqueCarregados(EstoqueFirestoreServer.helper.getProdutoEstoqueList()));
    } catch (_) {
      emit(ErroCarregarProdutosEstoque());
    }
  }

  void _carregarProduto(CarregarProdutoEstoque event, Emitter<ProdutoEstoqueState> emit) {
    emit(CarregandoProdutoEstoque());
    try {
      ProdutoEstoque produto = EstoqueFirestoreServer.helper.getProdutoEstoque(event.idProduto);
      emit(ProdutoDoEstoqueCarregado(produto));
    } catch (_) {
      emit(ErroCarregarProdutoEstoque());
    }
  }

  Future<void> _adicionarProduto(AdicionarAoEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    try {
      await EstoqueFirestoreServer.helper.insertProdutoEstoque(event.produto);
      emit(SucessoAoAdicionarProdutoEstoque());
    } on FormatException catch (erro) {
      emit(ErroAoAdicionararProdutoEstoque(erro.message));
    }
  }

  Future<void> _atualizarProduto(AtualizarProdutoDoEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    try {
      EstoqueFirestoreServer.helper.updateProdutoEstoque(event.produtoEstoque);
      emit(SucessoAoAtualizarProdutoEstoque());
    } on FormatException catch (erro) {
      emit(ErroAoAtualizarProdutoEstoque(erro.message));
    }
  }

  Future<void> _removerProduto(RemoverDoEstoque event, Emitter<ProdutoEstoqueState> emit) async {
    final state = this.state;
    if (state is ProdutoDoEstoqueCarregado) {
      try {
        await EstoqueFirestoreServer.helper.deleteProdutoEstoque(event.idProduto);
        emit(SucessoAoRemoverProdutoEstoque());
      } on FormatException catch (erro) {
        emit(ErroAoRemoverProdutoEstoque(erro.message));
        //para conseguir atualizar o produto mesmo após a ocorrencia de um erro de remoção
        emit(ProdutoDoEstoqueCarregado(state.produto));
      }
    } else {
      emit(ErroAoRemoverProdutoEstoque("Erro ao remover o produto! Caminho não estipulado"));
    }
  }
}
