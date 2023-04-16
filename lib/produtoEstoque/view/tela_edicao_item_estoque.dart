import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';

class TelaEdicaoProdutoEstoque extends StatelessWidget {
  int _opcaoAcesso = 0; //0 = add, 1 = edit
  String? idProduto;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ProdutoEstoqueBloc _produtoEstoqueBloc;

  String? _nomeProduto;
  String? _descricao;
  int? _quantidade;
  UNIDADE? _unidade;

  TelaEdicaoProdutoEstoque({this.idProduto}) {
    if (idProduto != null) _opcaoAcesso = 1;
  }

  @override
  Widget build(BuildContext context) {
    _produtoEstoqueBloc = BlocProvider.of<ProdutoEstoqueBloc>(context);
    if (_opcaoAcesso == 1) {
      _produtoEstoqueBloc.add(CarregarProdutoEstoque(idProduto!));
    }

    return SizedBox.expand(
      child: Scaffold(
        appBar: AppBar(
          title: _opcaoAcesso == 0 ? const Text('Adicionar novo Produto') : const Text('Atualizar Produto'),
        ),
        body: BlocConsumer<ProdutoEstoqueBloc, ProdutoEstoqueState>(
          buildWhen: (previous, current) => current is! EstadoDeErroProdutoEstoque && current is! EstadoDeSucessoProdutoEstoque,
          builder: (context, state) {
            if (idProduto != null) {
              if (state is CarregandoProdutoEstoque) {
                TelaCarregamento.gerarCorpoTelaCarregamento();
              }

              if (state is ErroCarregarProdutoEstoque) {
                return TelaErro.gerarCorpoTelaErro("Erro ao carregar o produto do estoque a ser atualizado");
              }

              if (state is ProdutoDoEstoqueCarregado) {
                _nomeProduto = state.produto.nomeProduto;
                _descricao = state.produto.descricao;
                _quantidade = state.produto.quantidade;
                _unidade = state.produto.unidade;
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _nomeProduto,
                      decoration: const InputDecoration(labelText: "Nome do produto"),
                      validator: (nome) {
                        if (nome != null) {
                          if (nome == "") {
                            return "Insira um nome válido";
                          }
                        }
                        return null;
                      },
                      onSaved: (nome) => _nomeProduto = nome,
                    ),
                    TextFormField(
                      initialValue: _descricao,
                      decoration: const InputDecoration(labelText: "Descrição"),
                      validator: (desc) {
                        if (desc != null) {
                          if (desc == "") {
                            return "Insira uma descrição válida";
                          }
                        }
                        return null;
                      },
                      onSaved: (desc) => _descricao = desc,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: _quantidade != null ? _quantidade.toString() : "",
                      decoration: const InputDecoration(labelText: "Quantidade"),
                      validator: (String? num) {
                        if (num != null) {
                          int? aux = int.tryParse(num);
                          if (aux != null) {
                            if (aux < 0) {
                              return "Insira um valor maior ou igual a 0.";
                            }
                          } else {
                            return "Insira um número válido";
                          }
                        }
                        return null;
                      },
                      onSaved: (String? num) => _quantidade = int.parse(num!),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text("Unidade de medida:"),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                            child: DropdownButtonFormField<String>(
                              value: _unidade != null ? _unidade!.index.toString() : null,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              isExpanded: true,
                              onChanged: (String? un) {
                                _unidade = UNIDADE.values[int.parse(un!)];
                              },
                              items: UNIDADE.values.map((
                                value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value.index.toString(),
                                  child: Text(describeEnum(value)),
                                );
                              }).toList(),
                              validator: (String? un) => un == null ? "Selecione uma unidade" : null,
                              onSaved: (String? un) {
                                _unidade = UNIDADE.values[int.parse(un!)];
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              if (_opcaoAcesso == 0) {
                                _produtoEstoqueBloc.add(
                                  AdicionarAoEstoque(
                                    ProdutoEstoque(_nomeProduto!, _descricao!, _quantidade!, _unidade!),
                                  ),
                                );
                              } else {
                                _produtoEstoqueBloc.add(
                                  AtualizarProdutoDoEstoque(
                                    ProdutoEstoque(_nomeProduto!, _descricao!, _quantidade!, _unidade!, id: idProduto),
                                  ),
                                );
                              }
                            }
                          },
                          child: _opcaoAcesso == 0 ? const Text("Cadastrar") : const Text("Salvar alterações"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          listener: (BuildContext context, state) {
            if (state is EstadoDeErroProdutoEstoque) {
              NotificacaoSnackBar.gerarSnackBar(context, "ERRO: " + state.erro);
            }
            if (state is EstadoDeSucessoProdutoEstoque) {
              NotificacaoSnackBar.gerarSnackBar(
                  context, _opcaoAcesso == 0 ? "Cadastro do produto concluído" : "Alterações no produto concluídas");
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
