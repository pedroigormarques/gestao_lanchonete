import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_event.dart';
import 'package:lanchonete/view/tela_carregamento.dart';

class TelaRegistro extends StatelessWidget {
  TelaRegistro({Key? key}) : super(key: key);
  String? _email;
  String? _senha;
  String? _nomeLanchonete;
  String? _endereco;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formkey = GlobalKey();
    return SizedBox.expand(
      child: Form(
        key: formkey,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Registrar conta',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  nomeEstabelecimentoFormField(),
                  enderecoFormField(),
                  emailFormField(),
                  senhaFormField(),
                  ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        formkey.currentState!.save();
                        TelaCarregamento.gerarDialogCarregando(
                            context, 'Registrando usuário...');
                        BlocProvider.of<AutenticacaoBloc>(context).add(
                            RegistrarUsuario(_email!, _senha!, _nomeLanchonete!,
                                _endereco!));
                      }
                    },
                    child: const Text("Registrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField senhaFormField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: const InputDecoration(labelText: "Senha"),
      validator: (senha) {
        if (senha!.length < 6) {
          return "Tem que ter ao menos 6 caracters";
        }
        return null;
      },
      onSaved: (senha) => _senha = senha!,
    );
  }

  TextFormField emailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: "Email"),
      validator: (String? email) {
        if (email == "") {
          return "Insira seu email";
        }
        return null;
      },
      onSaved: (email) => _email = email!,
    );
  }

  TextFormField nomeEstabelecimentoFormField() {
    return TextFormField(
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
