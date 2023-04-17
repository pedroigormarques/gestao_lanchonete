import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_state.dart';
import 'package:lanchonete/login/view/tela_acesso.dart';
import 'package:lanchonete/login/view/tela_registro.dart';
import 'package:lanchonete/pedidos/bloc/pedido_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';
import 'package:lanchonete/stream/bloc/stream_event.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';
import 'package:lanchonete/view/tela_principal.dart';

class TelaInicial extends StatelessWidget {
  bool _estavaLogadoAnteriormente = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutenticacaoBloc, AutenticacaoState>(
      listener: (context, state) {
        if (state is ErroDeAutenticacao) {
          Navigator.pop(context);
          TelaErro.gerarDialogErro(context, state.tituloErro, state.mensagem);
          //TelaCarregamento.gerarDialogCarregando(context, 'titulo teste');
        }
        if (state is ErroAtualizacao) {
          Navigator.pop(context);
          NotificacaoSnackBar.gerarSnackBar(
              context, "Erro ao atualizar: " + state.erro);
        }
        if (state is SucessoAtualizacao) {
          Navigator.pop(context);
          NotificacaoSnackBar.gerarSnackBar(context, state.mensagem);
        }
      },
      buildWhen: (previous, current) =>
          current is! ErroDeAutenticacao &&
          current is! ErroAtualizacao &&
          current is! SucessoAtualizacao &&
          !(current is Autenticado && previous is ErroAtualizacao),
      builder: (context, state) {
        if (state is Autenticado) {
          if (!_estavaLogadoAnteriormente) {
            Navigator.pop(context);
            BlocProvider.of<ProdutoEstoqueBloc>(context)
                .add(IniciarStream(state.usuario.uid));
            BlocProvider.of<ProdutoCardapioBloc>(context)
                .add(IniciarStream(state.usuario.uid));
            BlocProvider.of<PedidoBloc>(context)
                .add(IniciarStream(state.usuario.uid));
            _estavaLogadoAnteriormente = true;
          }
          return TelaPrincipal();
        } else {
          if (_estavaLogadoAnteriormente) {
            BlocProvider.of<ProdutoEstoqueBloc>(context).add(PararStream());
            BlocProvider.of<ProdutoCardapioBloc>(context).add(PararStream());
            BlocProvider.of<PedidoBloc>(context).add(PararStream());
            _estavaLogadoAnteriormente = false;
          }

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: TabBarView(
                children: [
                  const TelaAcesso(),
                  TelaRegistro(),
                ],
              ),
              appBar: AppBar(
                title: const Text("Sistema para lanchonetes"),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "Efetuar Login"),
                    Tab(text: "Novo Cadastro"),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
