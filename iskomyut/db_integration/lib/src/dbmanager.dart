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

  Future<Results> select(String table, {List<String>? columns, String? where, List<String>? joins, String? joinCondition, bool? close = true}) async {
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
      var query = 'SELECT ${columns != null ? columns.join(', ') : '*'} FROM $table ${joins != null ? joins.join(' ') : ''} ${where != null ? 'WHERE $where' : ''}';
      var result = await conn.query(query);

      /* 
        close boolean to close the connection when the query is done
        functions using transactions can let close = false to do other queries
      */
      if(close == true){
        await conn.close();
      }
      return result;
    }
    catch (e){
      await conn.close();
      print(e);
      throw DatabaseOperationException('Failed to execute SELECT query');
    }   
  }

  Future<List> getValues(String table, {List<String>? columns, String? where, List<String>? joins, bool? close = true}) async{
    //Gets the values from a select call and returns it as a list of rows
    var result = await select(table, columns: columns, where: where, joins: joins, close: close);
    var valueList = [];
    var it = result.iterator;

    while (it.moveNext()) {
      valueList.add(it.current);
    }

    return valueList;
  }

  Future<bool> isPresent(String table, {List<String>? columns, String? where,}) async {
    var result = await select(table, columns: columns, where: where);
    return (result.length == 1);
  }

  Future<bool> insert(String table, {List<String>? columns, String? where, required List<dynamic> values, bool? close = true}) async {
    var conn = await connect();
    
    try{
      //Using string interpolation to insert function parameters
      String query = 'INSERT INTO $table(${columns != null ? columns.join(', ') : ''}) VALUES (${values.join(', ')}) ${where != null ? 'WHERE $where' : ''}';
      await conn.query(query);
      
      if(close == true){
        await conn.close();
      }
      return true;
    }
    catch (e){
      await conn.close();
      throw DatabaseOperationException('Failed to execute INSERT query');
    }  
  }

  Future<bool> delete(String table, {required String where, bool? close = true}) async{
    var conn = await connect();

    try{
      //Using string interpolation to insert function parameters
      String query = 'DELETE FROM $table WHERE $where';
      await conn.query(query);
      
      if(close == true){
        await conn.close();
      }
      return true;
    }
    catch (e){
      await conn.close();
      throw DatabaseOperationException('Failed to execute DELETE query');
    } 
  }

  Future<bool> update(String table, {required List<dynamic> colVal, required String where, bool? close = true}) async{
    var conn = await connect();

    try{
      //Using string interpolation to insert function parameters
      String query = 'UPDATE $table SET ${colVal.join(', ')} WHERE $where';
      await conn.query(query);
      
      if(close == true){
        await conn.close();
      }
      return true;
    }
    catch (e){
      await conn.close();
      throw DatabaseOperationException('Failed to execute UPDATE query');
    } 
  }

  Future<bool> insertRouteAndSchedules({required Map<String, dynamic> insertRoute, required List<String> insertSchedule}) async{
    var conn = await connect();
    
    try{  
      await conn.query('START TRANSACTION ');

      bool insertRouteSQL = await insert('routes', columns: ['origin', 'destination', 'serviceprovider', 'price'], values: [insertRoute['origin'], insertRoute['destination'], insertRoute['serviceProvider'], insertRoute['price']], close: false);
      await conn.query('SET @routeId = LAST_INSERT_ID()');

      bool insertScheduleSQL = await insert('schedules', columns: ['routeId', 'date'], values: ['@routeId', insertSchedule.join(', ')], close: false);

      await conn.query('COMMIT');

      await conn.close();
      return true;
    }
    catch(e){
      await conn.close();
      throw DatabaseOperationException('Failed to insert route and schedules.');
    }
  }

  Future<bool> updateRouteAndSchedules({required Map<String, dynamic> updateRoute, required List<String> updateSchedule}) async{
    var conn = await connect();
    
    try{  
      await conn.query('START TRANSACTION ');

      bool updateRouteSQL = await update('routes', colVal: ['origin = ${updateRoute['origin']}', 'destination = ${updateRoute['destination']}', 'price = ${updateRoute['price']}'], where: 'id = ${updateRoute['routeID']}', close: false);

      bool updateScheduleSQL = await update('schedules', colVal: ['date = ${updateSchedule.join(',')}'], where: 'routeId = ${updateRoute['routeID']}', close: false);

      await conn.query('COMMIT');

      await conn.close();
      return true;
    }
    catch(e){
      await conn.close();
      throw DatabaseOperationException('Failed to insert route and schedules.');
    }
  }
}