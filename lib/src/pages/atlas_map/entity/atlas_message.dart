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
    var rawTx = await HYNApi.transCreateAtlasNode(this.entity, password, wallet);
    entity.rawTx = rawTx;

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
      fee: "0.000021",
    );
  }
}

class ConfirmEditAtlasNodeMessage implements AtlasMessage {
  final CreateAtlasEntity entity;
  ConfirmEditAtlasNodeMessage({this.entity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transCreateAtlasNode(this.entity, password, wallet);
    entity.rawTx = rawTx;

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
      fee: "0.000021",
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
    var rawTx = await HYNApi.transAtlasReceiveReward(this.pledgeAtlasEntity, password, wallet);
    pledgeAtlasEntity.rawTx = rawTx;

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
      fee: "0.000021",
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
    var rawTx = await HYNApi.transAtlasActive(this.entity, password, wallet);
    entity.rawTx = rawTx;

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
      fee: "0.000021",
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
    var rawTx = await HYNApi.transAtlasStake(this.pledgeAtlasEntity, password, wallet);
    pledgeAtlasEntity.rawTx = rawTx;

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
      toName: "Atlas节点",
      toDetail: "节点号:$nodeId",
      fee: "0.000021",
    );
  }
}

class ConfirmAtlasUnStakeMessage implements AtlasMessage {
  final String nodeId;
  final PledgeAtlasEntity pledgeAtlasEntity;
  ConfirmAtlasUnStakeMessage({this.nodeId, this.pledgeAtlasEntity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasUnStake(this.pledgeAtlasEntity, password, wallet);
    pledgeAtlasEntity.rawTx = rawTx;

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
      title: "撤销抵押",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Atlas链",
      toDetail: "",
      fee: "0.000021",
    );
  }
}

//==================================Atlas Message End==============================================

class ConfirmCreateMap3NodeMessage implements AtlasMessage {
  final CreateMap3Entity entity;
  ConfirmCreateMap3NodeMessage({this.entity});

  @override
  Future<bool> action(String password) async {
    try {
      print("[object] --> 2");

      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transCreateMap3Node(this.entity, password, wallet);
      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().postCreateMap3Node(this.entity);
      print("[Confirm] rawTx:$rawTx, txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      print(e);
    }

    return false;
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
      fee: "0.000021",
    );
  }
}

class ConfirmEditMap3NodeMessage implements AtlasMessage {
  final CreateMap3Entity entity;
  final String map3NodeAddress;
  ConfirmEditMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transEditMap3Node(this.entity, password, this.map3NodeAddress, wallet);
    this.entity.rawTx = rawTx;

    TxHashEntity txHashEntity = await AtlasApi().postEditMap3Node(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
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
      fee: "0.000021",
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
      fee: "0.000021",
    );
  }
}

class ConfirmTerminateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmTerminateMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transTerminateMap3Node(password, this.entity.to, this.map3NodeAddress, wallet);
    this.entity.rawTx = rawTx;

    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
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
      fromDetail: "节点号:${entity?.payload?.map3NodeId ?? ""}",
      amount: entity?.payload?.staking ?? "0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.000021",
    );
  }
}

class ConfirmCancelMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmCancelMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx =
        await HYNApi.transUnMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);
    this.entity.rawTx = rawTx;

    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
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
      fromDetail: "节点号:${entity?.payload?.map3NodeId ?? ""}",
      amount: entity?.payload?.staking ?? "0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.000021",
    );
  }
}

class ConfirmDelegateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmDelegateMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx =
        await HYNApi.transMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);

    this.entity.rawTx = rawTx;
    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
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
      toDetail: "节点号:${entity?.payload?.map3NodeId ?? ""}",
      amount: entity?.payload?.staking ?? "0",
      fee: "0.000021",
    );
  }
}

class ConfirmCollectMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;

  ConfirmCollectMap3NodeMessage({this.entity});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transCollectMap3Node(password, this.entity.to, wallet);

    this.entity.rawTx = rawTx;
    TxHashEntity txHashEntity = await AtlasApi().getMap3Reward(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
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
      fromDetail: "节点号:${entity?.payload?.map3NodeId ?? ""}",
      amount: entity?.payload?.staking ?? "0",
      toName: "钱包",
      toDetail: "$walletName ($address)",
      fee: "0.000021",
    );
  }
}

class ConfirmDivideMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmDivideMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<bool> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx =
        await HYNApi.transMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);
    this.entity.rawTx = rawTx;

    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_ADD;

  @override
  ConfirmInfoDescription get description {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var address = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);

    return ConfirmInfoDescription(
      title: "节点分裂",
      amountDirection: "-",
      fromName: "钱包",
      fromDetail: "$walletName ($address)",
      toName: "Map3节点",
      toDetail: "节点号:${entity?.payload?.map3NodeId ?? ""}",
      amount: entity?.payload?.staking ?? "0",
      fee: "0.000021",
    );
  }
}
