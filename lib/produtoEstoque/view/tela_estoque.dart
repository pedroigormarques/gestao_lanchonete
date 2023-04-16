import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/produtoEstoque/view/tela_edicao_item_estoque.dart';
import 'package:lanchonete/produtoEstoque/view/tela_produto_estoque.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaEstoque extends StatelessWidget {
  late final ProdutoEstoqueBloc _produtoEstoqueBloc;

  @override
  Widget build(BuildContext context) {
    _produtoEstoqueBloc = BlocProvider.of<ProdutoEstoqueBloc>(context);
    _produtoEstoqueBloc.add(CarregarProdutosEstoque());

    return Scaffold(
      body: BlocBuilder<ProdutoEstoqueBloc, ProdutoEstoqueState>(
        builder: (context, state) {
          if (state is CarregandoProdutosEstoque) {
            return TelaCarregamento.gerarCorpoTelaCarregamento();
          }

          if (state is ProdutosDoEstoqueCarregados) {
            return ListView.builder(
              itemCount: state.produtosEstocados.length,
              itemBuilder: (context, index) {
                String nomeProduto = state.produtosEstocados[index].nomeProduto;
                String id = state.produtosEstocados[index].id;
                String descricao = state.produtosEstocados[index].descricao;
                int quantidade = state.produtosEstocados[index].quantidade;
                UNIDADE unidade = state.produtosEstocados[index].unidade;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 10,
                  color: const Color.fromRGBO(240, 229, 207, 1),
                  child: ListTile(
                    isThreeLine: true,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder: (context, animation1, secondaryAnimation) => TelaProdutoEstoque(id)),
                      );
                      _produtoEstoqueBloc.add(CarregarProdutosEstoque());
                    },
                    title: Text(
                      nomeProduto,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      'Estocado: $quantidade ${describeEnum(unidade)}',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    subtitle: Text(
                      'Descricao: $descricao',
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            );
          }

          return TelaErro.gerarCorpoTelaErro("Erro ao carregar os produtos!");
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AdicionarProdutoEstoque",
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (context, animation1, secondaryAnimation) => TelaEdicaoProdutoEstoque()),
          );
          _produtoEstoqueBloc.add(CarregarProdutosEstoque());
        },
      ),
    );
  }
}
