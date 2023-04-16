import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/pedidos/bloc/pedido_bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_state.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/view/dialog_confirmacao.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaPedido extends StatelessWidget {
  TelaPedido(this.pedidoId);

  final String pedidoId;
  late List<ProdutoCardapio> _produtosCardapio;

  late final PedidoBloc _pedidoBloc;

  final String _tituloDaPagina = 'Informações do Pedido';

  @override
  Widget build(BuildContext context) {
    _pedidoBloc = BlocProvider.of<PedidoBloc>(context);
    _pedidoBloc.add(CarregarPedido(pedidoId));

    return BlocBuilder<ProdutoCardapioBloc, ProdutoCardapioState>(
      builder: (context, stateProdutosCardapio) {
        if (stateProdutosCardapio is CarregandoProdutosCardapio) {
          return TelaCarregamento.gerarTelaCarregamento(_tituloDaPagina);
        }

        if (stateProdutosCardapio is ErroCarregarProdutosCardapio) {
          return TelaErro.gerarTelaErro(_tituloDaPagina, "Erro ao carregar os produtos do cardapio para dar continuidade no pedido");
        }

        if (stateProdutosCardapio is ProdutosDoCardapioCarregados) {
          _produtosCardapio = stateProdutosCardapio.produtosCardapio;

          return BlocConsumer<PedidoBloc, PedidoState>(
            buildWhen: (previous, current) => current is! EstadoDeErroPedido && current is! EstadoDeSucessoPedido,
            builder: (context, statePedido) {
              if (statePedido is CarregandoPedido) {
                return TelaCarregamento.gerarTelaCarregamento(_tituloDaPagina);
              }

              if (statePedido is ErroCarregarPedido) {
                return TelaErro.gerarTelaErro(_tituloDaPagina, "Erro ao carregar as informações do pedido");
              }

              if (statePedido is PedidoCarregado) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(_tituloDaPagina),
                    actions: [
                      IconButton(
                        onPressed: () {
                          GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                          ProdutoCardapio? produtoSelecionado;
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('Qual o produto a ser adicionado?'),
                                  actions: [
                                    Form(
                                      key: _formKey,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButtonFormField<String>(
                                          icon: const Icon(Icons.arrow_drop_down),
                                          elevation: 16,
                                          isExpanded: true,
                                          onChanged: (String? un) {
                                            produtoSelecionado = _produtosCardapio[int.parse(un!)];
                                          },
                                          items: _produtosCardapio.asMap().entries.map(
                                            (entry) {
                                              return DropdownMenuItem<String>(
                                                value: entry.key.toString(),
                                                child: Text(entry.value.nomeProduto),
                                              );
                                            },
                                          ).toList(),
                                          validator: (String? un) => un == null ? "Selecione um produto" : null,
                                          onSaved: (String? un) {
                                            produtoSelecionado = _produtosCardapio[int.parse(un!)];
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                Navigator.pop(context, true);
                                              }
                                            },
                                            child: const Text('Adicionar produto'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).then((resposta) {
                            if (resposta) {
                              _pedidoBloc.add(AdicionarItemPedido(pedidoId, produtoSelecionado!));
                            }
                          });
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                      ),
                      IconButton(
                        onPressed: () {
                          DialogConfirmacao.gerarDialogConfirmacao(context, 'Deseja realmente fechar este pedido?').then((resposta) {
                            if (resposta) {
                              _pedidoBloc.add(FecharPedido(statePedido.pedido));
                            }
                          });
                        },
                        icon: const Icon(Icons.shopping_cart_checkout),
                      ),
                      IconButton(
                        onPressed: () {
                          DialogConfirmacao.gerarDialogConfirmacao(context, 'Deseja realmente cancelar este pedido?').then((reposta) {
                            if (reposta) {
                              _pedidoBloc.add(RemoverPedido(statePedido.pedido));
                            }
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  body: SizedBox.expand(
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
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mesa: ${statePedido.pedido.mesa}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
                              Text(
                                'Valor total: R\$${statePedido.pedido.valorConta.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(25.0),
                          width: double.maxFinite,
                          height: 80,
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          child: Text(
                            'Horario de abertura: ${DateFormat("HH:mm:ss dd/MM/yyyy").format(statePedido.pedido.horaAbertura)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Itens pedidos:',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: _gerarItensPedido(statePedido.pedido),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return TelaErro.gerarTelaErro(_tituloDaPagina, "Erro ao carregar informações do pedido");
            },
            listener: (BuildContext context, state) {
              if (state is EstadoDeErroPedido) {
                NotificacaoSnackBar.gerarSnackBar(context, "ERRO: " + state.erro);
              }

              if (state is EstadoDeSucessoPedido) {
                NotificacaoSnackBar.gerarSnackBar(context, state.mensagem);
              }

              if (state is SucessoAoFecharPedido || state is SucessoAoRemoverPedido) {
                Navigator.pop(context);
              }
            },
          );
        }

        return TelaErro.gerarTelaErro(_tituloDaPagina, "Erro inesperado ao carregar os produtos do cardapio.");
      },
    );
  }

  ListView _gerarItensPedido(Pedido pedido) {
    return ListView.builder(
      itemCount: pedido.produtosVendidos.length,
      itemBuilder: (context, index) {
        ProdutoCardapio item = pedido.produtosVendidos.keys.toList()[index];
        int quantidade = pedido.produtosVendidos.values.toList()[index];

        return Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.nomeProduto,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Subtotal: R\$ ${(item.preco * quantidade).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Quantidade:',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, top: 10),
                        decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _pedidoBloc.add(AdicionarQuantidadeItemPedido(pedidoId, item, 1));
                                },
                                icon: const Icon(Icons.add)),
                            Text(
                              quantidade.toString(),
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            IconButton(
                              onPressed: () {
                                if (quantidade == 1) {
                                  DialogConfirmacao.gerarDialogConfirmacao(context, "Dejesa remover este produto dos itens pedidos?")
                                      .then(
                                    (resposta) {
                                      if (resposta) {
                                        _pedidoBloc.add(RemoverItemPedido(pedidoId, item));
                                      }
                                    },
                                  );
                                } else {
                                  _pedidoBloc.add(RemoverQuantidadeItemPedido(pedidoId, item, 1));
                                }
                              },
                              icon: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      DialogConfirmacao.gerarDialogConfirmacao(context, "Dejesa remover este produto dos itens pedidos?")
                          .then((resposta) {
                        if (resposta) {
                          _pedidoBloc.add(RemoverItemPedido(pedidoId, item));
                        }
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Excluir"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
