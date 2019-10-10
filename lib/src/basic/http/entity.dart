typedef EntityGetter<T> = T Function(dynamic data);

class EntityFactory<T> {
  const EntityFactory(this.constructor) : assert(constructor != null);

  final EntityGetter<T> constructor;

  Type get type => T;

  @override
  String toString() {
    return 'EntityFactory(type: $type)';
  }
}

class ResponseCode {
  static const int SUCCESS = 0;
  static const int FAILED = -1;
}

class ResponseEntity<T> {
  final int code;
  final String msg;
  final T data;

  ResponseEntity._({this.code, this.msg, this.data});

  factory ResponseEntity.fromJson(Map<String, dynamic> json, {EntityFactory<T> factory}) {
    return ResponseEntity._(code: json['code'] ?? ResponseCode.FAILED, msg: json['msg'] ?? '', data: factory?.constructor(json['data']));
  }
}
