class Usuario {
  late final String uid;
  late final String email;
  late final String nomeLanchonete;
  late final String endereco;

  Usuario(this.uid, this.email, this.nomeLanchonete, this.endereco);

  Usuario.fromMap(dados) {
    uid = dados['id'];
    email = dados['email'];
    nomeLanchonete = dados['nomeLanchonete'];
    endereco = dados['endereco'];
  }
}
