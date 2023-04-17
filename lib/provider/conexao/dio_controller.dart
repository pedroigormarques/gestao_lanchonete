import 'package:dio/dio.dart';
import 'package:lanchonete/provider/conexao/dados_provider.dart';

class DioController {
  static DioController instance = DioController._createInstance();
  DioController._createInstance() {
    _dioAreaRestrita.interceptors
        .add(InterceptorsWrapper(onError: _errorInterceptor));
  }

  final _dioAreaRestrita = Dio();
  static Dio get dioSemCabecalho => Dio();
  Dio get dioAreaRestrita => _dioAreaRestrita;

  String _autorizacao = "Bearer ";
  String? _emailRenovarToken;
  String? _senhaRenovarToken;

  String get autorizacao => _autorizacao;
  void _setAutorizacao(String tokenAcessoAtual) {
    _autorizacao = "Bearer $tokenAcessoAtual";
    _dioAreaRestrita.options.headers["Authorization"] = _autorizacao;
  }

  void setSenhaRenovacaoToken(String? senha) {
    _senhaRenovarToken = senha;
  }

  void setEmailRenovacaoToken(String? email) {
    _emailRenovarToken = email;
  }

  void setDadosAcessoLogin(
    String tokenAcesso,
    String emailRenovarToken,
    String senhaRenovarToken,
  ) {
    setEmailRenovacaoToken(emailRenovarToken);
    setSenhaRenovacaoToken(senhaRenovarToken);
    _setAutorizacao(tokenAcesso);
  }

  void limparDadosAcesso() {
    setEmailRenovacaoToken(null);
    setSenhaRenovacaoToken(null);
    _setAutorizacao('');
  }

  Future<void> renovarAutorizacao() async {
    try {
      Response response = await dioSemCabecalho.post(
        DadosProvider.localUsuario + '/entrar',
        data: {'email': _emailRenovarToken, 'senha': _senhaRenovarToken},
      );

      if (response.statusCode != 200) throw 'erro';
      _setAutorizacao(response.data['token']);
    } catch (_) {
      throw const FormatException('Erro ao renovar o token de acesso');
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
    );

    return await _dioAreaRestrita.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  _errorInterceptor(DioError error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {
      await renovarAutorizacao();
      Response response = await _retry(error.requestOptions);
      handler.resolve(response);
    }
    handler.next(error);
  }
}
