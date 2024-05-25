import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'sqldetails.env')
abstract class Env {
    @EnviedField(varName: 'host')
    static final String host = _Env.host;
    @EnviedField(varName: 'port')
    static final int port = _Env.port;
    @EnviedField(varName: 'user')
    static final String user = _Env.user;
    @EnviedField(varName: 'password')
    static final String password = _Env.password;
    @EnviedField(varName: 'db')
    static final String db = _Env.db;
}