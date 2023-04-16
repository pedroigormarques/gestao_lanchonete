
import 'package:lanchonete/pedidos/models/pedido.dart';

abstract class PedidoState {
}

class CarregandoPedidos extends PedidoState {}

class ErroCarregarPedidos extends PedidoState {}

class PedidosCarregados extends PedidoState {
  final List<Pedido> listaPedidos;

  PedidosCarregados(this.listaPedidos);
}


class CarregandoPedido extends PedidoState {}

class ErroCarregarPedido extends PedidoState {}

class PedidoCarregado extends PedidoState {
  final Pedido pedido;

  PedidoCarregado(this.pedido);
}


abstract class EstadoDeErroPedido extends PedidoState {
  final String erro;

  EstadoDeErroPedido(this.erro);
}

abstract class EstadoDeSucessoPedido extends PedidoState {
  final String mensagem;

  EstadoDeSucessoPedido(this.mensagem);
}




class ErroAoAtualizarPedido extends EstadoDeErroPedido{
  ErroAoAtualizarPedido(String erro) : super(erro);
}

class SucessoAoAtualizarPedido extends EstadoDeSucessoPedido{
  SucessoAoAtualizarPedido(String mensagem) : super(mensagem);
}



class ErroAoAdicionarPedido extends EstadoDeErroPedido{
  ErroAoAdicionarPedido(String erro) : super(erro);
}

class SucessoAoAdicionarPedido extends EstadoDeSucessoPedido{
  SucessoAoAdicionarPedido(String mensagem) : super(mensagem);
}


class ErroAoRemoverPedido extends EstadoDeErroPedido{
  ErroAoRemoverPedido(String erro) : super(erro);
}

class SucessoAoRemoverPedido extends EstadoDeSucessoPedido{
  SucessoAoRemoverPedido(String mensagem) : super(mensagem);
}


class ErroAoFecharPedido extends EstadoDeErroPedido{
  ErroAoFecharPedido(String erro) : super(erro);
}

class SucessoAoFecharPedido extends EstadoDeSucessoPedido{
  SucessoAoFecharPedido(String mensagem) : super(mensagem);
}


class ErroAoAdicionarItemPedido extends EstadoDeErroPedido{
  ErroAoAdicionarItemPedido(String erro) : super(erro);
}

class SucessoAoAdicionarItemPedido extends EstadoDeSucessoPedido{
  SucessoAoAdicionarItemPedido(String mensagem) : super(mensagem);
}


class ErroAoRemoverItemPedido extends EstadoDeErroPedido{
  ErroAoRemoverItemPedido(String erro) : super(erro);
}

class SucessoAoRemoverItemPedido extends EstadoDeSucessoPedido{
  SucessoAoRemoverItemPedido(String mensagem) : super(mensagem);
}


class ErroAoAlterarQuantidadeItemPedido extends EstadoDeErroPedido{
  ErroAoAlterarQuantidadeItemPedido(String erro) : super(erro);
}

class SucessoAoAlterarQuantidadeItemPedido extends EstadoDeSucessoPedido{
  SucessoAoAlterarQuantidadeItemPedido(String mensagem) : super(mensagem);
}

