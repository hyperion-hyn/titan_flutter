class UpdateEntity {
  final int build;
  final String versionName;
  final String content;
  final int forceUpdate;
  final String md5;
  final String downloadUrl;

  UpdateEntity._({this.build, this.versionName, this.content, this.forceUpdate, this.md5, this.downloadUrl});

  factory UpdateEntity.fromJson(Map<String, dynamic> json) {
    return UpdateEntity._(
        build: json['build'] ?? 0,
        versionName: json['version_name'] ?? '',
        content: json['content'] ?? '',
        forceUpdate: json['force_update'] ?? 0,
        md5: json['md5'] ?? '',
        downloadUrl: json['download_url'] ?? '');
  }
}
