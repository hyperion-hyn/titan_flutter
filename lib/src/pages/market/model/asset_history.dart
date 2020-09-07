import 'package:json_annotation/json_annotation.dart';

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
        return '钱包到交易账户';
      case 'withdraw':
        return '交易账户到钱包';
      case 'running':
        return '系统赠币';
      default:
        return '-';
    }
  }

  String getStatusText() {
    if ((name ?? '') == 'recharge') {
      switch (status) {
        case '0':
          return '等待处理';
        case '1':
          return '等待确认';
        case '2':
          return '完成确认';
        default:
          return '-';
      }
    } else if ((name ?? '') == 'withdraw') {
      switch (status) {
        case '1':
          return '已提交';
        case '2':
          return '机器驳回';
        case '3':
          return '人工驳回';
        case '4':
          return '同意';
        case '5':
          return '处理中';
        case '6':
          return '处理完成';
        case '7':
          return '处理失败';
        case '8':
          return '用户取消';
        default:
          return '-';
      }
    } else if ((name ?? '') == 'running') {
      switch (status) {
        case '1':
          return '分红';
        case '2':
          return '空投';
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
