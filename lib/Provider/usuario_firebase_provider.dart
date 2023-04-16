import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lanchonete/login/models/usuario.dart';

class UsuarioService {
  final FirebaseAuth _autenticacaoFirebase = FirebaseAuth.instance;

  Stream<Usuario?> get usuario {
    return _autenticacaoFirebase.userChanges().asyncMap((user) => _converterUserParaUsuario(user));
  }

  Future<Usuario?> _converterUserParaUsuario(User? user) async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance.collection("dados_usuarios").doc(user.uid).get();
      Map<String, dynamic> dados = doc.data()!;
      return Usuario(user.uid, user.email!, dados["nomeLanchonete"], dados["endereco"]);
    }
    return null;
  }

  Future<void> logar(String email, String senha) async {
    try {
      await _autenticacaoFirebase.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (erro) {
      switch (erro.code) {
        case "invalid-email":
          throw const FormatException("Formato de email inválido.");
        case "wrong-password":
        case "user-not-found":
          throw const FormatException("Email ou senha inválidos. Verifique os dados e tente novamente.");
        case "user-disabled":
          throw const FormatException("A conta encontra-se desabilitada no momento.");

        default:
          throw FormatException(erro.message!);
      }
    }
  }

  Future<void> registrar(String email, String senha, String nomeLanchonete, String endereco) async {
    try {
      UserCredential userCredential = await _autenticacaoFirebase.createUserWithEmailAndPassword(email: email, password: senha);
      if (userCredential.user != null) {
        FirebaseFirestore.instance
            .collection("dados_usuarios")
            .doc(userCredential.user!.uid)
            .set({"nomeLanchonete": nomeLanchonete, "endereco": endereco});
      }
    } on FirebaseAuthException catch (erro) {
      switch (erro.code) {
        case "invalid-email":
          throw const FormatException("Formato de email inválido.");
        case "email-already-in-use":
          throw const FormatException("Email já registrado no sistema.");

        default:
          throw FormatException(erro.message!);
      }
    }
  }

  Future<void> deslogar() async {
    return await _autenticacaoFirebase.signOut();
  }

  Future<void> atualizarInformacoes(String nomeLanchonete, String endereco) async {
    await FirebaseFirestore.instance
        .collection("dados_usuarios")
        .doc(_autenticacaoFirebase.currentUser!.uid)
        .update({"nomeLanchonete": nomeLanchonete, "endereco": endereco});
  }

  Future<void> atualizarEmailAcesso(String senhaAtual, String novoEmail) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: _autenticacaoFirebase.currentUser!.email!, password: senhaAtual);
      UserCredential userCredential = await _autenticacaoFirebase.currentUser!.reauthenticateWithCredential(credential);
      if (userCredential.user != null) {
        await _autenticacaoFirebase.currentUser!.updateEmail(novoEmail);
      }
    } on FirebaseAuthException catch (erro) {
      switch (erro.code) {
        case "invalid-email":
          throw const FormatException("Formato de email inválido.");
        case "email-already-in-use":
          throw const FormatException("Email já registrado no sistema.");
        case "wrong-password":
          throw const FormatException("Senha de acesso inválida. Verifique os dados e tente novamente.");

        default:
          throw FormatException(erro.message!);
      }
    }
  }

  Future<void> atualizarSenhaAcesso(String senhaAtual, String novaSenha) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: _autenticacaoFirebase.currentUser!.email!, password: senhaAtual);
      UserCredential userCredential = await _autenticacaoFirebase.currentUser!.reauthenticateWithCredential(credential);
      if (userCredential.user != null) {
        await _autenticacaoFirebase.currentUser!.updatePassword(novaSenha);
      }
    } on FirebaseAuthException catch (erro) {
      switch (erro.code) {
        case "wrong-password":
          throw const FormatException("Senha de acesso inválida. Verifique os dados e tente novamente.");
        default:
          throw FormatException(erro.message!);
      }
    }
  }
}
