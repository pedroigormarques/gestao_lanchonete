import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_event.dart';
import 'package:lanchonete/login/bloc/autenticacao_state.dart';
import 'package:lanchonete/login/models/usuario.dart';

class TelaAtualizar extends StatelessWidget {
  TelaAtualizar({Key? key}) : super(key: key);
  late String _nomeLanchonete;
  late String _endereco;
  String? _novaSenha;
  String? _senhaAtual;
  String? _novoEmail;

  @override
  Widget build(BuildContext context) {
    Usuario _usuario = (BlocProvider.of<AutenticacaoBloc>(context).state as Autenticado).usuario;
    _nomeLanchonete = _usuario.nomeLanchonete;
    _endereco = _usuario.endereco;

    return SizedBox.expand(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            width: double.maxFinite,
            height: 160,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(color: Colors.grey[400]),
            child: const Text(
              "Dados do Usuário:",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Email: ${_usuario.email}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                    child: Text(
                      "Nome da lanchonete: ${_usuario.nomeLanchonete}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                    child: Text(
                      "Endereço: ${_usuario.endereco}",
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  atualizarDado(context, _corpoAtualizacaoDados()).then((resposta) {
                    if (resposta) BlocProvider.of<AutenticacaoBloc>(context).add(AtualizarInformacoes(_nomeLanchonete, _endereco));
                  });
                },
                child: const Text("Atualizar Dados"),
              ),
              ElevatedButton(
                onPressed: () {
                  atualizarDado(context, _corpoAtualizacaoEmail()).then((resposta) {
                    if (resposta) BlocProvider.of<AutenticacaoBloc>(context).add(AtualizarEmail(_novoEmail!, _senhaAtual!));
                  });
                },
                child: const Text("Alterar email"),
              ),
              ElevatedButton(
                onPressed: () {
                  atualizarDado(context, _corpoAtualizacaoSenha()).then((resposta) {
                    if (resposta) BlocProvider.of<AutenticacaoBloc>(context).add(AtualizarSenha(_senhaAtual!, _novaSenha!));
                  });
                },
                child: const Text("Alterar senha"),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _corpoAtualizacaoEmail() {
    return [emailFormField(), senhaAtualFormField()];
  }

  List<Widget> _corpoAtualizacaoSenha() {
    return [senhaAtualFormField(), senhaNovaFormField()];
  }

  List<Widget> _corpoAtualizacaoDados() {
    return [nomeEstabelecimentoFormField(), enderecoFormField()];
  }

  Future<bool> atualizarDado(BuildContext context, List<Widget> corpoAtualicacao) async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Insira os dados para atualizar.'),
            actions: [
              Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: corpoAtualicacao,
                    )),
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
                      child: const Text('Atualizar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  TextFormField senhaNovaFormField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: const InputDecoration(labelText: "Nova senha"),
      validator: (senha) {
        if (senha!.length < 6) {
          return "Tem que ter ao menos 6 caracters";
        }
        return null;
      },
      onSaved: (senha) => _novaSenha = senha!,
    );
  }

  TextFormField senhaAtualFormField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: const InputDecoration(labelText: "Confirme a sua senha"),
      validator: (senha) {
        if (senha!.length < 6) {
          return "Tem que ter ao menos 6 caracters";
        }
        return null;
      },
      onSaved: (senha) => _senhaAtual = senha!,
    );
  }

  TextFormField emailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: "Novo email de acesso"),
      validator: (String? email) {
        if (email == "") {
          return "Insira um email";
        }
        return null;
      },
      onSaved: (email) => _novoEmail = email!,
    );
  }

  TextFormField nomeEstabelecimentoFormField() {
    return TextFormField(
      initialValue: _nomeLanchonete,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(labelText: "Nome da lanchonete"),
      validator: (String? nome) {
        if (nome == "") {
          return "Insira o nome da lanchonete";
        }
        return null;
      },
      onSaved: (nome) => _nomeLanchonete = nome!,
    );
  }

  TextFormField enderecoFormField() {
    return TextFormField(
      initialValue: _endereco,
      keyboardType: TextInputType.streetAddress,
      decoration: const InputDecoration(labelText: "Endereço da lanchonete"),
      validator: (String? endereco) {
        if (endereco == "") {
          return "Insira o endereço da lanchonete";
        }
        return null;
      },
      onSaved: (endereco) => _endereco = endereco!,
    );
  }
}
