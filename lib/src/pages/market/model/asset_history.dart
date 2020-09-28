import 'package:json_annotation/json_annotation.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

part 'asset_history.g.dart';

@JsonSerializable()
class AssetHistory extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'balance')
  String balance;

  @JsonKey(name: 'fee')
  String fee;

  @JsonKey(name: 'tx_id')
  String txId;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'mtime')
  String mtime;

  @JsonKey(name: 'ctime')
  String ctime;

  String getTypeText() {
    switch (name ?? '') {
      case 'recharge':
        return S.of(Keys.rootKey.currentContext).recharge;
      case 'withdraw':
        return S.of(Keys.rootKey.currentContext).withdrawal;
      case 'running':
        return S.of(Keys.rootKey.currentContext).exchange_system_bonus;
      default:
        return '-';
    }
  }

  String getStatusText() {
    if ((name ?? '') == 'recharge') {
      switch (status) {
        case '1':
          return S.of(Keys.rootKey.currentContext).exchange_recharge_status_1;
        case '2':
          return S.of(Keys.rootKey.currentContext).exchange_recharge_status_2;
        default:
          return '-';
      }
    } else if ((name ?? '') == 'withdraw') {
      switch (status) {
        case '1':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_1;
        case '2':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_2;
        case '3':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_3;
        case '4':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_4;
        case '5':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_5;
        case '6':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_6;
        case '7':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_7;
        case '8':
          return S.of(Keys.rootKey.currentContext).exchange_withdraw_status_8;
        default:
          return '-';
      }
    } else if ((name ?? '') == 'running') {
      switch (status) {
        case '1':
          return S
              .of(Keys.rootKey.currentContext)
              .exchange_assets_running_status_1;
        case '2':
          return S
              .of(Keys.rootKey.currentContext)
              .exchange_assets_running_status_2;
        default:
          return '-';
      }
    } else {
      return '-';
    }
  }

  AssetHistory(
    this.name,
    this.id,
    this.type,
    this.balance,
    this.fee,
    this.txId,
    this.status,
    this.mtime,
    this.ctime,
  );

  factory AssetHistory.fromJson(Map<String, dynamic> srcJson) =>
      _$AssetHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AssetHistoryToJson(this);
}
