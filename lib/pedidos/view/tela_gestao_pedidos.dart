import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_state.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaGestaoPedidos extends StatelessWidget {
  late final PedidoFechadoBloc _pedidoFechadoBloc;
  DateTimeRange? periodo;

  @override
  Widget build(BuildContext context) {
    _pedidoFechadoBloc = BlocProvider.of<PedidoFechadoBloc>(context);
    _pedidoFechadoBloc.add(CarregarListaPedidos());

    return Scaffold(
      body: BlocBuilder<PedidoFechadoBloc, PedidoFechadoState>(
        builder: (context, state) {
          if (state is CarregandoPedidosFechados) {
            return TelaCarregamento.gerarCorpoTelaCarregamento();
          }

          if (state is PedidosFechadosCarregados) {
            return SizedBox.expand(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.date_range),
                            title: Text(
                              periodo != null
                                  ? "De: " +
                                      DateFormat("dd/MM/yyyy").format(periodo!.start.toLocal()) +
                                      " Até:" +
                                      DateFormat("dd/MM/yyyy").format(periodo!.end.toLocal())
                                  : "Filtre pelo período",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: periodo != null
                                ? IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      periodo = null;
                                      BlocProvider.of<PedidoFechadoBloc>(context).add(CarregarListaPedidosFiltrados(null));
                                    },
                                  )
                                : null,
                            onTap: () async {
                              DateTimeRange? aux = await showDateRangePicker(
                                locale: const Locale('pt', 'BR'),
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (aux != null) {
                                periodo = DateTimeRange(
                                    start: aux.start, end: aux.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)));
                                BlocProvider.of<PedidoFechadoBloc>(context).add(CarregarListaPedidosFiltrados(periodo!));
                              }
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                        const Text(
                          'Valor Total Recebido:',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                        Text(
                          'R\$${state.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Produtos vendidos:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: ListView.builder(
                        itemCount: state.produtosCardapioVendidos.length,
                        itemBuilder: (context, index) {
                          String nomeproduto = state.produtosCardapioVendidos.keys.elementAt(index);
                          int quantidade = state.produtosCardapioVendidos[nomeproduto]!;
                          return _gerarCardProduto(nomeproduto, quantidade);
                        },
                      ),
                    ),
                  ),
                  const Text(
                    'Produtos utilizados:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: ListView.builder(
                        itemCount: state.produtosEstoqueUsados.length,
                        itemBuilder: (context, index) {
                          String nomeproduto = state.produtosEstoqueUsados.keys.elementAt(index);
                          int quantidade = state.produtosEstoqueUsados[nomeproduto]!;
                          return _gerarCardProduto(nomeproduto, quantidade);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return TelaErro.gerarCorpoTelaErro("Erro ao carregar o histórico de pedidos!");
        },
      ),
    );
  }

  Card _gerarCardProduto(String nomeProduto, int quantidade) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 10,
      color: const Color.fromRGBO(240, 229, 207, 1),
      child: ListTile(
        title: Text(
          nomeProduto,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          'Qtd: $quantidade',
          style: const TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }
}
