import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/utils/utils.dart';

import 'create_atlas_entity.dart';

abstract class AtlasMessage {
  Future<bool> action(String password);
  Map3NodeActionEvent get type;
  ConfirmInfoDescription get description;
}

class ConfirmInfoDescription {
  final String title;
  final String amountDirection; // -,+
  final String amount;
  final String fromName;
  final String fromDetail;
  final String toName;
  final String toDetail;
  final String fee;

  ConfirmInfoDescription(
      {this.title,
      this.amountDirection,
      this.amount,
      this.fromName,
      this.fromDetail,
      this.toName,
      this.toDetail,
      this.fee});
}

//==================================Atlas Message Begin==============================================

class ConfirmCreateAtlasNodeMessage implements AtlasMessage {
  final CreateAtlasEntity entity;
  ConfirmCreateAtlasNodeMessage({this.entity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transCreateAtlasNode(this.entity, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postCreateAtlasNode(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_CREATE;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认创建Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.0000021",
    );
  }
}

class ConfirmEditAtlasNodeMessage implements AtlasMessage {
  final CreateAtlasEntity entity;
  ConfirmEditAtlasNodeMessage({this.entity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transCreateAtlasNode(this.entity, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postEditAtlasNode(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_EDIT;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认编辑Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.0000021",
    );
  }
}

class ConfirmAtlasReceiveAwardMessage implements AtlasMessage {
  final String nodeId;
  final PledgeAtlasEntity pledgeAtlasEntity;
  ConfirmAtlasReceiveAwardMessage({this.nodeId, this.pledgeAtlasEntity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transAtlasReceiveReward(this.pledgeAtlasEntity, password, wallet);
//
    TxHashEntity txHashEntity = await AtlasApi().getAtlasReward(this.pledgeAtlasEntity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_RECEIVE_AWARD;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "提取奖励",
      amountDirection: "+",
      amount: "0",
      fromName: "Atlas节点",
      fromDetail: "节点号:$nodeId",
      toName: "Map3节点",
      toDetail: "",
      fee: "0.0000021",
    );
  }
}

class ConfirmAtlasActiveMessage implements AtlasMessage {
  final String nodeId;
  final CreateAtlasEntity entity;
  ConfirmAtlasActiveMessage({this.nodeId, this.entity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transAtlasActive(this.entity, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().activeAtlasNode(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_ACTIVE_NODE;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "激活节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas链",
      toDetail: "",
      fee: "0.0000021",
    );
  }
}

class ConfirmAtlasStakeMessage implements AtlasMessage {
  final String nodeId;
  final PledgeAtlasEntity pledgeAtlasEntity;
  ConfirmAtlasStakeMessage({this.nodeId, this.pledgeAtlasEntity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transAtlasStake(this.pledgeAtlasEntity, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postPledgeAtlas(this.pledgeAtlasEntity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_STAKE;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "抵押Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas链",
      toDetail: "",
      fee: "0.0000021",
    );
  }
}

//==================================Atlas Message End==============================================


class ConfirmCreateMap3NodeMessage implements AtlasMessage {
  final CreateMap3Entity entity;
  ConfirmCreateMap3NodeMessage({this.entity});

  /*@override
  Future<bool> action(String password) async {
    TxHashEntity txHashEntity = await AtlasApi().postCreateMap3Node(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transCreateMap3Node(this.entity, password, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/

  @override
  Future<bool> action(String password) async {
    print("[ConfirmCreateMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CREATE;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认创建节点",
      amountDirection: "-",
      amount: entity.payload.staking,
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Map3节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.0000021",
    );
  }
}


class ConfirmEditMap3NodeMessage implements AtlasMessage {
  final CreateMap3Entity entity;
  final String map3NodeAddress;
  ConfirmEditMap3NodeMessage({this.entity, this.map3NodeAddress});

  /*@override
  Future<bool> action(String password) async {
    // TxHashEntity txHashEntity = await AtlasApi().postCreateMap3Node(this.entity);
    // print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transEditMap3Node(this.entity, password, this.map3NodeAddress, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/

  @override
  Future<bool> action(String password) async {
    print("[ConfirmEditMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_EDIT;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认编辑节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Map3节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.0000021",
    );
  }
}


class ConfirmPreEditMap3NodeMessage implements AtlasMessage {
  final bool autoRenew;
  final String feeRate;
  ConfirmPreEditMap3NodeMessage({this.autoRenew, this.feeRate});


  @override
  Future<bool> action(String password) async {
    print("[ConfirmPreEditMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_PRE_EDIT;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认修改预设",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas链",
      toDetail: "",
      fee: "0.0000021",
    );
  }
}

class ConfirmTerminateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmTerminateMap3NodeMessage({this.entity, this.map3NodeAddress});

  /*@override
  Future<bool> action(String password) async {
    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transTerminateMap3Node(password, this.entity.to, this.map3NodeAddress, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/

  @override
  Future<bool> action(String password) async {
    print("[ConfirmEditMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_TERMINAL;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认终止节点",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "节点号:${entity?.payload?.map3NodeId??""}",
      amount: entity?.payload?.staking??"0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.0000021",
    );
  }
}

class ConfirmCancelMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmCancelMap3NodeMessage({this.entity, this.map3NodeAddress});

  /*@override
  Future<bool> action(String password) async {
    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transUnMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/



  @override
  Future<bool> action(String password) async {
    print("[ConfirmEditMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CANCEL;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认撤销",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "节点号:${entity?.payload?.map3NodeId??""}",
      amount: entity?.payload?.staking??"0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.0000021",
    );
  }
}

class ConfirmDelegateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmDelegateMap3NodeMessage({this.entity, this.map3NodeAddress});

  /*@override
  Future<bool> action(String password) async {
    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/


  @override
  Future<bool> action(String password) async {
    print("[ConfirmDelegateMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_DELEGATE;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "确认抵押节点",
      amountDirection: "-",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Map3节点",
      toDetail: "节点号:${entity?.payload?.map3NodeId??""}",
      amount: entity?.payload?.staking??"0",
      fee: "0.0000021",
    );
  }
}


class ConfirmCollectMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmCollectMap3NodeMessage({this.entity, this.map3NodeAddress});

  /*@override
  Future<bool> action(String password) async {
    TxHashEntity txHashEntity = await AtlasApi().getMap3Reward(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    HYNApi.transCollectMap3Node(password, this.entity.to, this.map3NodeAddress, wallet);
    return txHashEntity.txHash.isNotEmpty;
  }*/


  @override
  Future<bool> action(String password) async {
    print("[ConfirmEditMap3NodeMessage] action:$password");
    return password.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_COLLECT;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "提取奖励",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "节点号:${entity?.payload?.map3NodeId??""}",
      amount: entity?.payload?.staking??"0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.0000021",
    );
  }
}


/*
activatedWallet = WalletInheritedModel.of(context).activatedWallet;
var myActiveShortAddr = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);
switch (widget.actionEvent) {
case Map3NodeActionEvent.DELEGATE:
_pageTitle = S.of(context).transfer_confirm;
break;
case Map3NodeActionEvent.COLLECT:
_pageTitle = "提取奖励";
break;
case Map3NodeActionEvent.CANCEL:
break;
case Map3NodeActionEvent.CANCEL_CONFIRMED:
break;
case Map3NodeActionEvent.ADD:
break;
case Map3NodeActionEvent.RECEIVE_AWARD:
_pageTitle = "提取奖励";
_subList[0] = "Atlas节点";
_subList[1] = "钱包";
_detailList = [
"节点号: ${widget.atlasNodeId}",
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr})",
"${widget.transferAmount} HYN"
];
break;
case Map3NodeActionEvent.EDIT_ATLAS:
_pageTitle = "确认编辑Atlas节点";
_subList[1] = "Atlas节点";
_detailList = [
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
"节点号: ${widget.atlasNodeId}",
"${widget.transferAmount} HYN"
];
break;
case Map3NodeActionEvent.ACTIVE_NODE:
_pageTitle = "激活节点";
_subList[1] = "Atlas链";
_detailList = [
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
"",
"${widget.transferAmount} HYN"
];
break;
case Map3NodeActionEvent.STAKE_ATLAS:
_pageTitle = "激活节点";
_subList[1] = "Atlas链";
_detailList = [
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
"",
"${widget.transferAmount} HYN"
];
break;
case Map3NodeActionEvent.EXCHANGE_HYN:
_pageTitle = "兑换HYN";
_titleList[2] = "网络费用";
_subList = ["ERC20钱包", "主链钱包", ""];
_detailList = [
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
""
];
break;

case Map3NodeActionEvent.PRE_EDIT:
_pageTitle = "修改预设";
_subList[1] = "Atlas节点";
_subList[0] = "钱包";
_detailList = [
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
"${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
""
];
break;

default:
_pageTitle = S.of(context).transfer_confirm;
break;
}
*/
