import 'package:mysql1/mysql1.dart';
import 'exceptions.dart';
import 'env.dart';

class DBManager{
  Future<MySqlConnection> connect() async{
    var settings = ConnectionSettings(

      host: Env.host,
      port: Env.port,
      user: Env.user,
      password: Env.password,
      db: Env.db,
    );

    try{
      return await MySqlConnection.connect(settings);
    }
    catch(e){
      print(e);
      throw DatabaseConnectionException('Failed to connect to the database');
    }
  }

  Future<Results> select(String table, {List<String>? columns, String? where}) async {
    /*
      Fix on issue that returns no value. 
      Fix based on: https://stackoverflow.com/questions/76017696/why-wont-my-mysql1-queries-in-dart-return-any-results
      by Kars, modified it so that the future.delayed function is before the result. Issue is due to the mysqli
      package does not await properly.
    */
    var conn = await connect();

    await Future.delayed(Duration(seconds: 2)); 
    try{
      //Using string interpolation to insert function parameters
      var result = await conn.query(
        'SELECT ${columns != null ? columns.join(', ') : '*'} FROM $table ${where != null ? 'WHERE $where' : ''}'
        );

      await conn.close();
      return result;
    }
    catch (e){
      await conn.close();
      print(e);
      throw DatabaseOperationException('Failed to execute SELECT query');
    }   
  }

  Future<bool> isPresent(String table, {List<String>? columns, String? where}) async {
    var result = await select(table, columns: columns, where: where);
    return (result.length == 1);
  }

  Future<bool> insert(String table, {List<String>? columns, String? where, required List<dynamic> values}) async {
    var conn = await connect();
    
    try{
      //Using string interpolation to insert function parameters
      String query = 'INSERT INTO $table(${columns != null ? columns.join(', ') : ''}) VALUES (${values.join(', ')}) ${where != null ? 'WHERE $where' : ''}';
      await conn.query(query);
      await conn.close();
      return true;
    }
    catch (e){
      await conn.close();
      throw DatabaseOperationException('Failed to execute SELECT query');
    }  
  }
}