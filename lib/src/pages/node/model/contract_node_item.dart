import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/node/model/node_item.dart';

part 'contract_node_item.g.dart';

@JsonSerializable()
class ContractNodeItem extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'contract')
  NodeItem contract;

  @JsonKey(name: 'owner')
  String owner;

  @JsonKey(name: 'ownerName')
  String ownerName;

  @JsonKey(name: 'amountDelegation')
  String amountDelegation;

  @JsonKey(name: 'remainDelegation')
  String remainDelegation;

  @JsonKey(name: 'nodeProvider')
  String nodeProvider;

  @JsonKey(name: 'nodeProviderName')
  String nodeProviderName;

  @JsonKey(name: 'nodeRegion')
  String nodeRegion;

  @JsonKey(name: 'nodeRegionName')
  String nodeRegionName;

  @JsonKey(name: 'expectDueTime')
  int expectDueTime;

  @JsonKey(name: 'expectCancelTime')
  int expectCancelTime;

  @JsonKey(name: 'instanceStartTime')
  int instanceStartTime;

  @JsonKey(name: 'instanceActiveTime')
  int instanceActiveTime;

  @JsonKey(name: 'instanceDueTime')
  int instanceDueTime;

  @JsonKey(name: 'instanceCancelTime')
  int instanceCancelTime;

  @JsonKey(name: 'instanceFinishTime')
  int instanceFinishTime;

  @JsonKey(name: 'shareUrl')
  String shareUrl;

  @JsonKey(name: 'remoteNodeUrl')
  String remoteNodeUrl;

//  enum ContractState { PRE_CREATE, PENDING, CANCELLED, CANCELLED_COMPLETED, ACTIVE, DUE, DUE_COMPLETED, FAIL}
  @JsonKey(name: 'state')
  String state;

  ContractNodeItem(
    this.id,
    this.contract,
    this.owner,
    this.ownerName,
    this.amountDelegation,
    this.remainDelegation,
    this.nodeProvider,
    this.nodeRegion,
    this.nodeRegionName,
    this.expectDueTime,
    this.expectCancelTime,
    this.instanceStartTime,
    this.instanceActiveTime,
    this.instanceDueTime,
    this.instanceCancelTime,
    this.instanceFinishTime,
    this.shareUrl,
    this.remoteNodeUrl,
    this.state,
  );

  ContractNodeItem.onlyNodeItem(this.contract);

  ContractNodeItem.onlyNodeId(this.id);

  factory ContractNodeItem.fromJson(Map<String, dynamic> srcJson) => _$ContractNodeItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractNodeItemToJson(this);

  ///启动剩余时间
  double get launcherSecondsLeft {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    int timeLeft = expectCancelTime - now;
    return timeLeft > 0 ? timeLeft : 0;
  }

//  String get remainDay {
//    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
//    double totalRemain = (expectCancelTime - instanceStartTime) / 3600 / 24;
//    double progress = ((now - instanceStartTime) / 3600 / 24);
//    return FormatUtil.doubleFormatNum(totalRemain >= progress ? totalRemain - progress : 0);
//  }

  double get remainProgress {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    int totalRemain = (expectCancelTime - instanceStartTime);
    double progress = (now - instanceStartTime) / totalRemain;

    return _adjustProgress(progress);
  }

//  String get expectDueDay {
//    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
//    double totalRemain = (expectDueTime - instanceActiveTime) / 3600 / 24;
//    double progress = ((now - instanceActiveTime) / 3600 / 24);
//    return FormatUtil.doubleFormatNum(totalRemain >= progress ? totalRemain - progress : 0);
//  }

  ///从启动到期满剩余时间
  double get completeSecondsLeft {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    int timeLeft = expectDueTime - now;
    return timeLeft > 0 ? timeLeft : 0;
  }

  double get expectDueProgress {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    int totalDue = (expectDueTime - instanceActiveTime);
    double progress = (now - instanceActiveTime) / totalDue;

    return _adjustProgress(progress);
  }

//  String get remainHalfDueDay {
//    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
//    double totalRemain = (expectDueTime - instanceActiveTime) / 3600 / 24 / 2;
//    double progress = ((now - instanceStartTime) / 3600 / 24);
//    return FormatUtil.doubleFormatNum(totalRemain >= progress ? totalRemain - progress : 0);
//  }

  ///从启动到中期剩余时间
  double get halfCompleteSecondsLeft {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    double timeLeft = (expectDueTime - now) / 2;
    return timeLeft > 0 ? timeLeft : 0;
  }

  double get expectHalfDueProgress {
    int now = (DateTime.now().millisecondsSinceEpoch * 0.001).toInt();
    int totalDue = (expectDueTime - instanceActiveTime);
    double progress = ((now - instanceActiveTime) * 2) / totalDue;

    return _adjustProgress(progress);
  }

  double _adjustProgress(double progress) {
    if (progress != double.infinity) {
      if (progress > 0.2 && progress <= 1.0) {
        return progress;
      } else if (progress > 1) {
        return 0.99;
      } else {
        return 0.2;
      }
    }

    return 0.0;
  }

  String get shortOwnerName {
    var shortOwnerName = ownerName;
    if (ownerName.length > 6) {
      shortOwnerName = ownerName.substring(0, 6);
      shortOwnerName = shortOwnerName + "...";
    }
    return shortOwnerName;
  }
}
