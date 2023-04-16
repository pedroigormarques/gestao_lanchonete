import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_event.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/cardapio/view/tela_edicao_item_cardapio.dart';
import 'package:lanchonete/cardapio/view/tela_produto_cardapio.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaCardapio extends StatelessWidget {
  late final ProdutoCardapioBloc _produtoCardapioBloc;

  @override
  Widget build(BuildContext context) {
    _produtoCardapioBloc = BlocProvider.of<ProdutoCardapioBloc>(context);
    _produtoCardapioBloc.add(CarregarProdutosCardapio());

    return Scaffold(
      body: BlocBuilder<ProdutoCardapioBloc, ProdutoCardapioState>(
        builder: (context, state) {
          if (state is CarregandoProdutosCardapio) {
            return TelaCarregamento.gerarCorpoTelaCarregamento();
          }

          if (state is ProdutosDoCardapioCarregados) {
            return ListView.builder(
              itemCount: state.produtosCardapio.length,
              itemBuilder: (context, index) {
                String nomeProduto = state.produtosCardapio[index].nomeProduto;
                String id = state.produtosCardapio[index].id;
                String descricao = state.produtosCardapio[index].descricao;
                double preco = state.produtosCardapio[index].preco;
                CATEGORIAS categoria = state.produtosCardapio[index].categoria;
                String composicao = "";
                state.produtosCardapio[index].composicao.forEach((key, value) {
                  composicao += " ${key.nomeProduto}($value ${describeEnum(key.unidade)});";
                });

                if (index == 0 || state.produtosCardapio[index - 1].categoria != categoria) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[400],
                        ),
                        child: Text(
                          describeEnum(categoria),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      _gerarCardProdutoCardapio(context, id, nomeProduto, categoria, preco, descricao, composicao),
                    ],
                  );
                } else {
                  return _gerarCardProdutoCardapio(context, id, nomeProduto, categoria, preco, descricao, composicao);
                }
              },
            );
          }

          return TelaErro.gerarCorpoTelaErro("Erro ao carregar os produtos!");
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AdicionarProdutoCardapio",
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (context, animation1, secondaryAnimation) => TelaEdicaoItemCardapio(),
            ),
          );
          _produtoCardapioBloc.add(CarregarProdutosCardapio());
        },
      ),
    );
  }

  Card _gerarCardProdutoCardapio(
      BuildContext context, String id, String nomeProduto, CATEGORIAS categoria, double preco, String descricao, String composicao) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      color: const Color.fromRGBO(240, 229, 207, 1),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (context, animation1, secondaryAnimation) => TelaProdutoCardapio(id),
            ),
          );
          _produtoCardapioBloc.add(CarregarProdutosCardapio());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                nomeProduto,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categoria: ${describeEnum(categoria)}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  Text(
                    'Preço: RS ${preco.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
              child: Text(
                'Descrição: $descricao',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
              child: Text(
                'Composição: $composicao',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
