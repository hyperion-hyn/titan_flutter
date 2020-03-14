import 'package:json_annotation/json_annotation.dart'; 
  
part 'map3_node_vo.g.dart';


@JsonSerializable()
  class Map3NodeVo extends Object {

  @JsonKey(name: 'dmapperDownloads')
  List<dynamic> dmapperDownloads;

  @JsonKey(name: 'dmapperUsers')
  List<dynamic> dmapperUsers;

  @JsonKey(name: 'hynTokenUsers')
  List<dynamic> hynTokenUsers;

  @JsonKey(name: 'tileRequests')
  List<dynamic> tileRequests;

  @JsonKey(name: 'tileTotalRequests')
  int tileTotalRequests;

  @JsonKey(name: 'tiles')
  List<Tiles> tiles;

  @JsonKey(name: 'totalDmapperDownloads')
  int totalDmapperDownloads;

  @JsonKey(name: 'totalDmapperUsers')
  int totalDmapperUsers;

  @JsonKey(name: 'totalHynTokenUsers')
  int totalHynTokenUsers;

  @JsonKey(name: 'totalTiles')
  int totalTiles;

  Map3NodeVo(this.dmapperDownloads,this.dmapperUsers,this.hynTokenUsers,this.tileRequests,this.tileTotalRequests,this.tiles,this.totalDmapperDownloads,this.totalDmapperUsers,this.totalHynTokenUsers,this.totalTiles,);

  factory Map3NodeVo.fromJson(Map<String, dynamic> srcJson) => _$Map3NodeVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3NodeVoToJson(this);

}

  
@JsonSerializable()
  class Tiles extends Object {

  @JsonKey(name: 'id')
  Id id;

  @JsonKey(name: 'count')
  int count;

  Tiles(this.id,this.count,);

  factory Tiles.fromJson(Map<String, dynamic> srcJson) => _$TilesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TilesToJson(this);

}

  
@JsonSerializable()
  class Id extends Object {

  @JsonKey(name: 'city')
  String city;

  @JsonKey(name: 'location')
  List<double> location;

  Id(this.city,this.location,);

  factory Id.fromJson(Map<String, dynamic> srcJson) => _$IdFromJson(srcJson);

  Map<String, dynamic> toJson() => _$IdToJson(this);

}

  
