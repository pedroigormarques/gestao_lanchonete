import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_event.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/cardapio/view/tela_edicao_item_cardapio.dart';
import 'package:lanchonete/view/dialog_confirmacao.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaProdutoCardapio extends StatelessWidget {
  String idProduto;
  final String _tituloDaPagina = 'Informações do Produto';

  TelaProdutoCardapio(this.idProduto);

  late final ProdutoCardapioBloc _produtoCardapioBloc;

  @override
  Widget build(BuildContext context) {
    _produtoCardapioBloc = BlocProvider.of<ProdutoCardapioBloc>(context);
    _produtoCardapioBloc.add(CarregarProdutoCardapio(idProduto));

    return BlocConsumer<ProdutoCardapioBloc, ProdutoCardapioState>(
      buildWhen: (previous, current) =>
          current is! EstadoDeErroProdutoCardapio &&
          current is! EstadoDeSucessoProdutoCardapio,
      builder: (context, state) {
        String _composicao = "";
        if (state is ProdutoDoCardapioCarregado) {
          state.produto.composicao.forEach((key, value) {
            _composicao +=
                " ${key.nomeProduto}($value ${describeEnum(key.unidade)});";
          });
        }

        if (state is CarregandoProdutoCardapio) {
          return TelaCarregamento.gerarTelaCarregamento(_tituloDaPagina);
        }

        if (state is ProdutoDoCardapioCarregado) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_tituloDaPagina),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder:
                              (context, animation1, secondaryAnimation) =>
                                  TelaEdicaoItemCardapio(idProduto: idProduto)),
                    );
                    _produtoCardapioBloc
                        .add(CarregarProdutoCardapio(idProduto));
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    DialogConfirmacao.gerarDialogConfirmacao(
                            context, 'Deseja realmente remover este produto?')
                        .then(
                      (resposta) {
                        if (resposta) {
                          TelaCarregamento.gerarDialogCarregando(
                              context, 'Removendo produto do cardápio...');
                          _produtoCardapioBloc
                              .add(RemoverDoCardapio(state.produto));
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    width: double.maxFinite,
                    height: 160,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(color: Colors.grey[400]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.produto.nomeProduto,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0)),
                        Text(
                          'Quantidade produzível: ${state.produto.visualizarQuantidade().toString()}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(25.0),
                    width: double.maxFinite,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categoria: ${describeEnum(state.produto.categoria)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Preço: RS ${state.produto.preco.toStringAsFixed(2)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Descrição: ${state.produto.descricao}',
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                            child: Text(
                              'Composição: $_composicao',
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return TelaErro.gerarTelaErro(
            _tituloDaPagina, "Erro ao carregar informações do produto");
      },
      listener: (BuildContext context, state) {
        if (state is ErroAoRemoverProdutoCardapio ||
            state is SucessoAoRemoverProdutoCardapio) {
          Navigator.pop(context); //remove o carregamento
        }
        if (state is ErroAoRemoverProdutoCardapio) {
          NotificacaoSnackBar.gerarSnackBar(context, "ERRO: " + state.erro);
        }
        if (state is SucessoAoRemoverProdutoCardapio) {
          NotificacaoSnackBar.gerarSnackBar(
              context, "Produto removido com sucesso");
          Navigator.pop(context);
        }
      },
    );
  }
}
