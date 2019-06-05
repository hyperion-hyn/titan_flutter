class HistorySearchEntity {
  final double time;
  final String searchText;

  HistorySearchEntity({this.time, this.searchText});

  Map<String, Object> toJson() {
    return {'time': time, 'searchText': searchText};
  }

  factory HistorySearchEntity.fromJson(Map<String, Object> json) {
    return HistorySearchEntity(time: json['time'] ?? 0, searchText: json['searchText']);
  }
}
