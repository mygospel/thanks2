class Memo {
  final int id;
  final String title;
  final String cont;
  final String dt;
  final String createTime;
  final String editTime;

  Memo(
      {this.id = 0,
      this.title = '',
      this.cont = '',
      this.dt = '',
      this.createTime = '',
      this.editTime = ''});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'cont': cont,
      'dt': dt,
      'createTime': createTime,
      'editTime': editTime,
    };
  }

  // 각 memo 정보를 보기 쉽도록 print 문을 사용하여 toString을 구현하세요
  @override
  String toString() {
    return 'Memo{id: $id, title: $title, cont: $cont, dt: $dt, createTime: $createTime, editTime: $editTime}';
  }
}
