import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_bloc.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_event.dart';
import 'package:lanchonete/cardapio/bloc/produto_cardapio_state.dart';
import 'package:lanchonete/cardapio/models/produto_cardapio.dart';
import 'package:lanchonete/produtoEstoque/Models/produto_estoque.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_bloc.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_event.dart';
import 'package:lanchonete/produtoEstoque/bloc/produto_estoque_state.dart';
import 'package:lanchonete/view/notificacao_snackbar.dart';
import 'package:lanchonete/view/tela_carregamento.dart';
import 'package:lanchonete/view/tela_erro.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class TelaEdicaoItemCardapio extends StatefulWidget {
  late List<ProdutoEstoque> produtosEstoque;
  int opcaoAcesso = 0;
  late ProdutoCardapioBloc _produtoCardapioBloc;

  bool _produtoCarregado = false;
  ProdutoCardapio? _produtoCardapioAntigo;

  late final String? idProduto;

  TelaEdicaoItemCardapio({this.idProduto}) {
    if (idProduto != null) {
      opcaoAcesso = 1;
    }
  }

  @override
  State<TelaEdicaoItemCardapio> createState() => _TelaEdicaoItemCardapioState();
}

class _TelaEdicaoItemCardapioState extends State<TelaEdicaoItemCardapio> {
  String? _nomeProduto;
  String? _descricao;
  Map<ProdutoEstoque, int> _composicao = {};
  double? _preco;
  CATEGORIAS? _categoria;

  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  _stepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else {
      return StepState.editing;
    }
  }

  _steps() => [
        Step(
          title: const Text('Informações do Produto'),
          content: Form(
            key: _formKeys[0],
            child: _produtoCardapioForm(),
          ),
          state: _stepState(0),
          isActive: _currentStep == 0,
        ),
        Step(
          title: const Text('Composição'),
          content: Form(
            key: _formKeys[1],
            child: _composicaoProdutoForm(),
          ),
          state: _stepState(1),
          isActive: _currentStep == 1,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ProdutoEstoqueBloc>(context).add(CarregarProdutosEstoque());
    widget._produtoCardapioBloc = BlocProvider.of<ProdutoCardapioBloc>(context);
    if (widget.opcaoAcesso == 1) {
      widget._produtoCardapioBloc
          .add(CarregarProdutoCardapio(widget.idProduto!));
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.opcaoAcesso == 0
            ? const Text('Adicionar novo Produto')
            : const Text('Atualizar Produto'),
      ),
      body: BlocBuilder<ProdutoEstoqueBloc, ProdutoEstoqueState>(
        builder: (context, stateProdutosEstoque) {
          if (stateProdutosEstoque is CarregandoProdutosEstoque) {
            return TelaCarregamento.gerarCorpoTelaCarregamento();
          }

          if (stateProdutosEstoque is ErroCarregarProdutosEstoque) {
            return TelaErro.gerarCorpoTelaErro(
                "Erro ao carregar os produtos do estoque para dar continuidade no processo de ${widget.opcaoAcesso == 0 ? "adição" : "atualização"}");
          }

          if (stateProdutosEstoque is ProdutosDoEstoqueCarregados) {
            widget.produtosEstoque = stateProdutosEstoque.produtosEstocados;

            return BlocConsumer<ProdutoCardapioBloc, ProdutoCardapioState>(
              buildWhen: (previous, current) =>
                  current is! EstadoDeErroProdutoCardapio &&
                  current is! EstadoDeSucessoProdutoCardapio,
              builder: (context, stateProdutoCardapio) {
                if (widget.idProduto != null &&
                    stateProdutoCardapio is CarregandoProdutoCardapio) {
                  return TelaCarregamento.gerarCorpoTelaCarregamento();
                }

                if (widget.idProduto != null &&
                    stateProdutoCardapio is ErroCarregarProdutoCardapio) {
                  return TelaErro.gerarCorpoTelaErro(
                      "Erro ao carregar o produto do cardapio a ser atualizado");
                }

                if (!widget._produtoCarregado &&
                    stateProdutoCardapio is ProdutoDoCardapioCarregado) {
                  widget._produtoCarregado = true;
                  widget._produtoCardapioAntigo = stateProdutoCardapio.produto;

                  _nomeProduto = stateProdutoCardapio.produto.nomeProduto;
                  _descricao = stateProdutoCardapio.produto.descricao;
                  _composicao = {...stateProdutoCardapio.produto.composicao};

                  _preco = stateProdutoCardapio.produto.preco;
                  _categoria = stateProdutoCardapio.produto.categoria;
                }

                return Stepper(
                  type: StepperType.horizontal,
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controls) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: controls.onStepContinue,
                            child: (_currentStep == _steps().length - 1)
                                ? const Text('Salvar')
                                : const Text('Continuar'),
                          ),
                          if (_currentStep != 0)
                            TextButton(
                              onPressed: controls.onStepCancel,
                              child: const Text(
                                'Voltar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  onStepTapped: (step) {
                    if (step < _currentStep) {
                      setState(() => _currentStep = step);
                    }
                  },
                  onStepContinue: () {
                    if (_formKeys[_currentStep].currentState!.validate()) {
                      _formKeys[_currentStep].currentState!.save();
                      if (_currentStep < _steps().length - 1) {
                        setState(() {
                          _currentStep += 1;
                        });
                      } else {
                        if (widget.opcaoAcesso == 0) {
                          TelaCarregamento.gerarDialogCarregando(
                              context, 'Adicionando produto ao cardápio...');
                          widget._produtoCardapioBloc.add(
                            AdicionarAoCardapio(
                              ProdutoCardapio(_nomeProduto!, _descricao!,
                                  _preco!, _categoria!, _composicao),
                            ),
                          );
                        } else {
                          TelaCarregamento.gerarDialogCarregando(
                              context, 'Atualizando produto do cardápio...');
                          widget._produtoCardapioBloc.add(
                            AtualizarProdutoDoCardapio(
                              widget._produtoCardapioAntigo!,
                              ProdutoCardapio(_nomeProduto!, _descricao!,
                                  _preco!, _categoria!, _composicao,
                                  id: widget.idProduto!),
                            ),
                          );
                        }
                      }
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    } else {
                      _currentStep = 0;
                    }
                  },
                  currentStep: _currentStep,
                  steps: _steps(),
                );
              },
              listener: (BuildContext context, state) {
                if (state is EstadoDeErroProdutoCardapio ||
                    state is EstadoDeSucessoProdutoCardapio) {
                  Navigator.pop(context); //remove o carregamento
                }
                if (state is EstadoDeErroProdutoCardapio) {
                  NotificacaoSnackBar.gerarSnackBar(
                      context, "ERRO: " + state.erro);
                }
                if (state is EstadoDeSucessoProdutoCardapio) {
                  NotificacaoSnackBar.gerarSnackBar(
                      context,
                      widget.opcaoAcesso == 0
                          ? "Cadastro do produto concluído"
                          : "Alterações no produto concluídas");
                  Navigator.pop(context);
                }
              },
            );
          }

          return TelaErro.gerarCorpoTelaErro(
              "Erro inesperado ao tentar editar partindo do produtos do estoque");
        },
      ),
    );
  }

  Widget _produtoCardapioForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: _nomeProduto,
              decoration: const InputDecoration(
                labelText: "Nome do produto",
              ),
              validator: (nome) {
                if (nome != null) {
                  if (nome == "") {
                    return "Insira um nome válido";
                  }
                }
                return null;
              },
              onSaved: (nome) => _nomeProduto = nome!,
            ),
            TextFormField(
              initialValue: _descricao,
              decoration: const InputDecoration(
                labelText: "Descrição",
              ),
              validator: (desc) {
                if (desc != null) {
                  if (desc == "") {
                    return "Insira uma descrição válida";
                  }
                }
                return null;
              },
              onSaved: (desc) => _descricao = desc!,
            ),
            TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              initialValue: _preco != null ? _preco!.toStringAsFixed(2) : null,
              decoration: const InputDecoration(
                labelText: "Preço(R\$): ",
              ),
              validator: (String? num) {
                if (num != null) {
                  double? aux = double.tryParse(num);
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
              onSaved: (String? num) => _preco = double.parse(num!),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text("Categoria:"),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300]),
                    child: DropdownButtonFormField<String>(
                      value: _categoria != null
                          ? _categoria!.index.toString()
                          : null,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      isExpanded: true,
                      onChanged: (String? un) {
                        _categoria = CATEGORIAS.values[int.parse(un!)];
                      },
                      items: CATEGORIAS.values.map((
                        value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value.index.toString(),
                          child: Text(describeEnum(value)),
                        );
                      }).toList(),
                      validator: (String? un) =>
                          un == null ? "Selecione uma categoria" : null,
                      onSaved: (String? un) {
                        _categoria = CATEGORIAS.values[int.parse(un!)];
                      },
                    ),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: const Text(
                "Composição:",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MultiSelectDialogField(
              initialValue: _composicao
                  .map((key, value) => MapEntry(
                      widget.produtosEstoque
                          .firstWhere((element) => element.id == key.id),
                      value))
                  .keys
                  .toList(),
              items: widget.produtosEstoque
                  .map((produto) => MultiSelectItem<ProdutoEstoque>(
                      produto, produto.nomeProduto))
                  .toList(),
              title: const Text("Produtos estocados"),
              buttonIcon: const Icon(Icons.edit),
              buttonText: const Text(
                "Editar ingredientes na composição",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              onConfirm: (List produtosSelecionados) {
                _composicao.removeWhere(
                    (key, value) => !produtosSelecionados.contains(key));
                for (var produtoSelecionado in produtosSelecionados) {
                  if (!_composicao.keys.contains(produtoSelecionado)) {
                    _composicao[produtoSelecionado] = -1;
                  }
                }
              },
              validator: (List<ProdutoEstoque>? produtosSelecionados) =>
                  produtosSelecionados!.isEmpty
                      ? "Selecione ao menos um produto"
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  _composicaoProdutoForm() {
    return Column(children: _gerarListaDeColetaDeIngredientes());
  }

  _gerarListaDeColetaDeIngredientes() {
    List<Widget> itens = [];

    _composicao.forEach((produto, quantidade) {
      itens.add(
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: ListTile(
            title: Text(
              produto.nomeProduto,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            subtitle: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: quantidade != -1 ? quantidade.toString() : "",
              decoration: InputDecoration(
                labelText: "Quantidade (${describeEnum(produto.unidade)})",
              ),
              validator: (String? num) {
                if (num != null) {
                  int? aux = int.tryParse(num);
                  if (aux != null) {
                    if (aux <= 0) {
                      return "Insira um valor maior que 0.";
                    }
                  } else {
                    return "Insira um número válido";
                  }
                }
                return null;
              },
              onSaved: (String? num) => _composicao[produto] = int.parse(num!),
            ),
          ),
        ),
      );
    });

    return itens;
  }
}
