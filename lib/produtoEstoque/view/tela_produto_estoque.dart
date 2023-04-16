import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/produtoEstoque/view/tela_edicao_item_estoque.dart';
import 'package:lanchonete/view/dialog_confirmacao.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaProdutoEstoque extends StatelessWidget {
  TelaProdutoEstoque(this._idProduto);

  static const String _tituloDaPagina = 'Informações do Produto';

  final String _idProduto;

  late final ProdutoEstoqueBloc _produtoEstoqueBloc;

  @override
  Widget build(BuildContext context) {
    _produtoEstoqueBloc = BlocProvider.of<ProdutoEstoqueBloc>(context);
    _produtoEstoqueBloc.add(CarregarProdutoEstoque(_idProduto));

    return BlocConsumer<ProdutoEstoqueBloc, ProdutoEstoqueState>(
      buildWhen: (previous, current) => current is! EstadoDeErroProdutoEstoque && current is! EstadoDeSucessoProdutoEstoque,
      builder: (context, state) {
        if (state is CarregandoProdutoEstoque) {
          return TelaCarregamento.gerarTelaCarregamento(_tituloDaPagina);
        }

        if (state is ProdutoDoEstoqueCarregado) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(_tituloDaPagina),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder: (context, animation1, secondaryAnimation) => TelaEdicaoProdutoEstoque(idProduto: _idProduto)),
                    );
                    _produtoEstoqueBloc.add(CarregarProdutoEstoque(_idProduto));
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    DialogConfirmacao.gerarDialogConfirmacao(context, 'Deseja realmente remover este produto?').then(
                      (resposta) {
                        if (resposta) {
                          _produtoEstoqueBloc.add(RemoverDoEstoque(_idProduto));
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
                        Text(
                          'Estoque: ${state.produto.quantidade} ${describeEnum(state.produto.unidade)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(25.0),
                      child: SingleChildScrollView(
                        child: Text(
                          'Descrição: ${state.produto.descricao}',
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return TelaErro.gerarTelaErro(_tituloDaPagina, "Erro ao carregar informações do produto");
      },
      listener: (BuildContext context, state) {
        if (state is ErroAoRemoverProdutoEstoque) {
          NotificacaoSnackBar.gerarSnackBar(context, "ERRO: " + state.erro);
        }
        if (state is SucessoAoRemoverProdutoEstoque) {
          NotificacaoSnackBar.gerarSnackBar(context, "Produto removido com sucesso");
          Navigator.pop(context);
        }
      },
    );
  }
}
