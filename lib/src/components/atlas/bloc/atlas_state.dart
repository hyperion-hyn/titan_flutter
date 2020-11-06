import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class AtlasState {}

class InitialAtlasState extends AtlasState {}

class UpdateAtlasHomeEntityState extends AtlasState {
  final AtlasHomeEntity atlasHomeEntity;

  UpdateAtlasHomeEntityState(this.atlasHomeEntity);
}
