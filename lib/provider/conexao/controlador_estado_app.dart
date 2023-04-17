import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lanchonete/provider/stream_provider.dart';

class ControladorApp with WidgetsBindingObserver {
  // Atributo que irá afunilar todas as consultas
  static ControladorApp? _instance;
  ControladorApp._createInstance(); // Construtor privado

  static void inicializar() async {
    if (_instance == null) {
      ControladorApp._instance = ControladorApp._createInstance();
    }
    WidgetsBinding.instance.addObserver(_instance!);
  }

  static Set<StreamProvider> a = <StreamProvider>{};

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    /*switch (state) {
      case AppLifecycleState.resumed:
        for (StreamProvider controlador in a) {
          controlador.iniciarConexao();
        }
        break;

      case AppLifecycleState.paused:
        for (StreamProvider controlador in a) {
          await controlador.finalizarConexao();
        }
        break;

      default:
        break;
    }*/
  }

  static addStreamProvider(StreamProvider controlador) {
    a.add(controlador);
    controlador.iniciarConexao();
  }

  static removerStreamProvider(StreamProvider controlador) {
    a.remove(controlador);
    controlador.finalizarConexao();
  }
}
