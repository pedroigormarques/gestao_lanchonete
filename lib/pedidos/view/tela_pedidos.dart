import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lanchonete/pedidos/bloc/pedido_bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_state.dart';
import 'package:lanchonete/pedidos/models/pedido.dart';
import 'package:lanchonete/pedidos/view/tela_pedido.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaPedidos extends StatelessWidget {
  late final PedidoBloc _pedidoBloc;

  @override
  Widget build(BuildContext context) {
    _pedidoBloc = BlocProvider.of<PedidoBloc>(context);
    _pedidoBloc.add(CarregarListaPedidos());

    return Scaffold(
      body: BlocConsumer<PedidoBloc, PedidoState>(
        buildWhen: (previous, current) => current is! EstadoDeErroPedido && current is! EstadoDeSucessoPedido,
        builder: (context, state) {
          if (state is CarregandoPedidos) {
            return TelaCarregamento.gerarCorpoTelaCarregamento();
          }

          if (state is PedidosCarregados) {
            return ListView.builder(
                itemCount: state.listaPedidos.length,
                itemBuilder: (context, index) {
                  String idPedido = state.listaPedidos[index].id;
                  int _mesa = state.listaPedidos[index].mesa;
                  String _horario = DateFormat("HH:mm:ss dd/MM/yyyy").format(state.listaPedidos[index].horaAbertura);
                  double _valorConta = state.listaPedidos[index].valorConta;

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
                              //transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder: (context, animation1, secondaryAnimation) => TelaPedido(idPedido)),
                        );
                        _pedidoBloc.add(CarregarListaPedidos());
                      },
                      title: Text(
                        'Mesa: ${_mesa.toString()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        'Total: R\$ ${_valorConta.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Chegada: $_horario',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  );
                });
          }

          return TelaErro.gerarCorpoTelaErro("Erro ao carregar os pedidos!");
        },
        listener: (BuildContext context, state) {
          if (state is ErroAoAdicionarPedido) {
            NotificacaoSnackBar.gerarSnackBar(context, "ERRO: " + state.erro);
          }
          if (state is SucessoAoAdicionarPedido) {
            NotificacaoSnackBar.gerarSnackBar(context, "Pedido aberto com sucesso");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AbrirPedido",
        child: const Icon(Icons.add),
        onPressed: () {
          GlobalKey<FormState> _formKey = GlobalKey<FormState>();
          int _mesa = 0;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return AlertDialog(
                  title: const Text('Qual o número da mesa?'),
                  actions: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Número da mesa"),
                          validator: (mesa) {
                            if (mesa != null) {
                              int? aux = int.tryParse(mesa);
                              if (aux != null) {
                                if (aux < 1) {
                                  return "Insira um valor maior que 0.";
                                }
                              } else {
                                return "Insira um número válido";
                              }
                            }
                            return null;
                          },
                          onSaved: (mesa) => _mesa = int.parse(mesa!),
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
                            child: const Text('Abrir pedido'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).then(
            (resposta) {
              if (resposta) _pedidoBloc.add(AdicionarPedido(Pedido(_mesa, {})));
            },
          );
        },
      ),
    );
  }
}
