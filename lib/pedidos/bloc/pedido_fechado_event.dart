import 'package:flutter/material.dart';

abstract class PedidoFechadoEvent {}

class CarregarListaPedidos extends PedidoFechadoEvent {}

class CarregarListaPedidosFiltrados extends PedidoFechadoEvent {
  DateTimeRange? periodo;
  CarregarListaPedidosFiltrados(this.periodo);
}

