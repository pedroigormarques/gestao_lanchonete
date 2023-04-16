import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_event.dart';
import 'package:lanchonete/login/bloc/autenticacao_state.dart';
import 'package:lanchonete/login/models/usuario.dart';
import 'package:lanchonete/login/view/tela_atualizar.dart';

import 'package:lanchonete/pedidos/view/tela_gestao_pedidos.dart';
import 'package:lanchonete/pedidos/view/tela_pedidos.dart';
import 'package:lanchonete/produtoEstoque/view/tela_estoque.dart';
import 'package:lanchonete/cardapio/view/tela_cardapio.dart';

class TelaPrincipal extends StatefulWidget {
  final List<String> _titlePage = ["Estoque", "Cardápio", "Pedidos", "Informações de funcionamento", "Atualizar dados"];

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentScreen = 0;
  

  @override
  Widget build(BuildContext context) {
    Usuario _usuario = (BlocProvider.of<AutenticacaoBloc>(context).state as Autenticado).usuario;

    return Scaffold(
      appBar: AppBar(title: Text(widget._titlePage[_currentScreen])),
      body: IndexedStack(
        index: _currentScreen,
        children: [
          TelaEstoque(),
          TelaCardapio(),
          TelaPedidos(),
          TelaGestaoPedidos(),
          TelaAtualizar(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                    "Informações do estabelecimento:\n" + _usuario.nomeLanchonete,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color.fromRGBO(247, 246, 242, 1),
                    ),
                    textAlign: TextAlign.center),
              ),
              decoration: const BoxDecoration(color: Color.fromARGB(255, 50, 84, 129)),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: Text(widget._titlePage[0]),
              onTap: () {
                setState(() {
                  _currentScreen = 0;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(widget._titlePage[1]),
              onTap: () {
                setState(() {
                  _currentScreen = 1;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_page),
              title: Text(widget._titlePage[2]),
              onTap: () {
                setState(() {
                  _currentScreen = 2;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(widget._titlePage[3]),
              onTap: () {
                setState(() {
                  _currentScreen = 3;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(widget._titlePage[4]),
              onTap: () {
                setState(() {
                  _currentScreen = 4;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
              onTap: () {
                BlocProvider.of<AutenticacaoBloc>(context).add(Deslogar());
              },
            ),
          ],
        ),
      ),
    );
  }
}
