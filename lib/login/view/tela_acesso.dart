import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_bloc.dart';
import 'package:lanchonete/login/bloc/autenticacao_event.dart';

class TelaAcesso extends StatelessWidget {
  const TelaAcesso({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formkey = GlobalKey();
    String? _email;
    String? _senha;
    return SizedBox.expand(
      child: Form(
        key: formkey,
        child: Center(
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
                const Text(
                  'Acessar conta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (String? email) {
                    if (email == "") {
                      return "Insira seu email";
                    }
                    return null;
                  },
                  onSaved: (email) => _email = email!,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Senha"),
                  validator: (senha) {
                    if (senha!.length < 6) {
                      return "Tem que ter ao menos 6 caracteres";
                    }
                    return null;
                  },
                  onSaved: (senha) => _senha = senha!,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      formkey.currentState!.save();
                      BlocProvider.of<AutenticacaoBloc>(context).add(LogarUsuario(_email!, _senha!));
                    }
                  },
                  child: const Text("Acessar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
