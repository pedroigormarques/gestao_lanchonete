import 'package:dio/dio.dart';

class ManipuladorErro {
  static FormatException gerarErro(erro, {bool logado = true}) {
    if (erro is FormatException) return erro;
    return FormatException(_localizarErro(erro, logado));
  }

  static String _localizarErro(erro, bool logado) {
    if (erro is DioError) {
      if (erro.type == DioErrorType.response) {
        if (!logado && erro.response!.statusCode == 401) {
          return "Email ou senha de acesso inválida. Verifique os dados e tente novamente.";
        }
        return _gerarErroDioResponse(erro.response!.data);
      }
    }
    return erro.toString();
  }

  static String _gerarErroDioResponse(dynamic dados) {
    if (dados['error'] != null) {
      return dados['error'];
    } else if (dados['errors'] != null) {
      return (dados['errors'] as List).join('; ');
    } else {
      return dados['message'];
    }
  }
}
