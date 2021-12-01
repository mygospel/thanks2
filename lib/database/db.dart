import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thanks2/database/memo.dart';

import '../calendar_util.dart';

final String TableName = 'memos';

class DBHelper {
  var _db;

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await openDatabase(
      // 데이터베이스 경로를 지정합니다. 참고: `path` 패키지의 `join` 함수를 사용하는 것이
      // 각 플랫폼 별로 경로가 제대로 생성됐는지 보장할 수 있는 가장 좋은 방법입니다.
      join(await getDatabasesPath(), 'memos4.db'),
      // 데이터베이스가 처음 생성될 때, dog를 저장하기 위한 테이블을 생성합니다.
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $TableName(id INTEGER PRIMARY KEY autoincrement, title TEXT, cont TEXT, dt varchar(10), createTime TEXT, editTime TEXT)
        ''',
        );
      },
      // 버전을 설정하세요. onCreate 함수에서 수행되며 데이터베이스 업그레이드와 다운그레이드를
      // 수행하기 위한 경로를 제공합니다.
      version: 1,
    );
    return _db;
  }

  Future<int> memosTotal() async {
    final db = await database;
    int count = 0;

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT count(*) as co FROM $TableName');

    count = maps[0]['co'];
    return count;
  }

  Future<int> memosToday(String dt) async {
    final db = await database;
    int count = 0;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT count(*) as co FROM $TableName where dt=?', [dt]);
    count = maps[0]['co'];
    return count;
  }

  Future<List<Memo>> memos() async {
    final db = await database;

    // 모든 Memo를 얻기 위해 테이블에 질의합니다.
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM $TableName order by dt desc, id desc');

    // List<Map<String, dynamic>를 List<Memo>으로 변환합니다.
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        cont: maps[i]['cont'],
        dt: maps[i]['dt'],
        createTime: maps[i]['createTime'] ?? "",
        editTime: maps[i]['editTime'] ?? "",
      );
    });
  }

  Future<List<Memo>> memosList(dt) async {
    final db = await database;

    // 모든 Memo를 얻기 위해 테이블에 질의합니다.

    List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM $TableName where dt=? order by id desc', [dt]);

    // List<Map<String, dynamic>를 List<Memo>으로 변환합니다.

    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        cont: maps[i]['cont'],
        dt: maps[i]['dt'],
        createTime: maps[i]['createTime'] ?? "",
        editTime: maps[i]['editTime'] ?? "",
      );
    });
  }

  Future<List<String>> memosList2Cal() async {
    final db = await database;

    // 모든 Memo를 얻기 위해 테이블에 질의합니다.
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM $TableName order by dt desc, id desc');

    // List<Map<String, dynamic>를 List<Memo>으로 변환합니다.
    return List.generate(maps.length, (i) {
      tEvent.addAll([Event(maps[i]['title'])]);

      return maps[i]['title'];
    });
  }

  Future<Memo> memoRead(id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM $TableName where id = $id');
    return Memo(
      id: maps[0]['id'],
      title: maps[0]['title'],
      cont: maps[0]['cont'],
      dt: maps[0]['dt'],
      createTime: maps[0]['createTime'] ?? "",
      editTime: maps[0]['editTime'] ?? "",
    );
  }

  Future<int> insertMemo(Memo memo) async {
    final db = await database;

    // Memo를 올바른 테이블에 추가하세요. 또한
    // `conflictAlgorithm`을 명시할 것입니다. 본 예제에서는
    // 만약 동일한 memo가 여러번 추가되면, 이전 데이터를 덮어쓸 것입니다.
    /*
    final int insertedId = await db.insert(
      TableName,
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    */
    int insertedId = await db.rawInsert(
        "INSERT INTO $TableName(title, cont, dt, createTime, editTime) VALUES(?,?,?,?,?)",
        [memo.title, memo.cont, memo.dt, memo.createTime, memo.editTime]);
    return insertedId;
  }

  Future<void> updateMemo(Memo memo) async {
    final db = await database;

    // 주어진 Memo를 수정합니다.
    await db.update(
      TableName,
      memo.toMap(),
      // Memo의 id가 일치하는 지 확인합니다.
      where: "id = ?",
      // Memo의 id를 whereArg로 넘겨 SQL injection을 방지합니다.
      whereArgs: [memo.id],
    );
  }

  Future<void> deleteMemo(int id) async {
    final db = await database;

    // 데이터베이스에서 Memo를 삭제합니다.
    await db.delete(
      TableName,
      // 특정 memo를 제거하기 위해 `where` 절을 사용하세요
      where: "id = ?",
      // Memo의 id를 where의 인자로 넘겨 SQL injection을 방지합니다.
      whereArgs: [id],
    );
  }
}
