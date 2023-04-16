import 'package:bloc/bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_event.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_state.dart';
import 'package:lanchonete/pedidos/models/pedido_fechado.dart';
import 'package:lanchonete/pedidos/models/pedidos_fechados.dart';
import 'package:lanchonete/Provider/pedido_provider.dart';

class PedidoFechadoBloc extends Bloc<PedidoFechadoEvent, PedidoFechadoState> {


  double _valorTotal = 0.0;
  Map<String, int> _produtosCardapioVendidos = {};
  Map<String, int> _produtosEstoqueUsados = {};

  PedidoFechadoBloc() : super(CarregandoPedidosFechados()) {
    on<CarregarListaPedidos>(_carregarListaPedidosFechados);
    on<CarregarListaPedidosFiltrados>(_atualizarListaComFiltro);
  }

  Future<void> _carregarListaPedidosFechados(CarregarListaPedidos event, Emitter<PedidoFechadoState> emit) async {
    emit(CarregandoPedidosFechados());
    try {
      ListaPedidosFechados listaPedidosFechados = await PedidosFirestoreServer.helper.getPedidosFechadosList();
      List<PedidoFechado> lista = listaPedidosFechados.carregarListaPedidosFechados();
      _calcularValores(lista);
      emit(PedidosFechadosCarregados(lista, _valorTotal, _produtosCardapioVendidos, _produtosEstoqueUsados));
    } catch (_) {
      emit(ErroCarregarPedidosFechados());
    }
  }

  void _atualizarListaComFiltro(CarregarListaPedidosFiltrados event, Emitter<PedidoFechadoState> emit) {
    var state = this.state;
    if (state is PedidosFechadosCarregados) {
      List<PedidoFechado> listaFiltrada;
      if (event.periodo == null) {
        listaFiltrada = state.listaPedidosOriginal;
      } else {
        listaFiltrada = state.listaPedidosOriginal
            .where((pedido) => pedido.horaAbertura.isAfter(event.periodo!.start) && pedido.horaAbertura.isBefore(event.periodo!.end))
            .toList();
      }
      _calcularValores(listaFiltrada);
      emit(PedidosFechadosCarregados(state.listaPedidosOriginal, _valorTotal, _produtosCardapioVendidos, _produtosEstoqueUsados));
    } else {
      emit(ErroCarregarPedidosFechados());
    }
  }

  void _calcularValores(List<PedidoFechado> lista) {
    _valorTotal = 0.0;
    _produtosCardapioVendidos.clear();
    _produtosEstoqueUsados.clear();

    for (PedidoFechado pedido in lista) {
      _valorTotal += pedido.valorConta;
      
      pedido.produtosVendidos.forEach((produto, qtd) {
        if (!_produtosCardapioVendidos.containsKey(produto)) {
          _produtosCardapioVendidos[produto] = 0;
        }
        _produtosCardapioVendidos.update(produto, (valor) => valor + qtd);
      });

      pedido.produtosUtilizados.forEach((produto, qtd) {
        if (!_produtosEstoqueUsados.containsKey(produto)) {
          _produtosEstoqueUsados[produto] = 0;
        }
        _produtosEstoqueUsados.update(produto, (valor) => valor + qtd);
      });
    }
    //ordenação descendente
    _produtosCardapioVendidos =
        Map.fromEntries(_produtosCardapioVendidos.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
    //ordenação alfabética
    _produtosEstoqueUsados = Map.fromEntries(_produtosEstoqueUsados.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }
}
