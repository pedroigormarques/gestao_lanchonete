import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/view/tela_inical.dart';

import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_bloc.dart';
import 'package:lanchonete/pedidos/bloc/pedido_fechado_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProdutoEstoqueBloc()),
        BlocProvider(create: (_) => ProdutoCardapioBloc()),
        BlocProvider(create: (_) => PedidoBloc()),
        BlocProvider(create: (_) => PedidoFechadoBloc()),
        BlocProvider(create: (_) => AutenticacaoBloc()),
      ],
      child: MaterialApp(
        title: 'Aplicativo para Lanchonete',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: TelaInicial(),
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: const [Locale('pt', "BR")],
      ),
    );
  }
}
