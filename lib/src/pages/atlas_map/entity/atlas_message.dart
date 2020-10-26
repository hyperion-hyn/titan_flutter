import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utils.dart';

import 'create_atlas_entity.dart';

abstract class AtlasMessage {
  Future<dynamic> action(String password);
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
  final List<dynamic> addressList;

  ConfirmInfoDescription({
    this.title,
    this.amountDirection,
    this.amount,
    this.fromName,
    this.fromDetail,
    this.toName,
    this.toDetail,
    this.fee,
    this.addressList,
  });
}

get _walletAddressAndName {
  var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
  var walletName = activatedWallet?.wallet?.keystore?.name ?? "";
  var hynAddress = WalletUtil.ethAddressToBech32Address(activatedWallet?.wallet?.getEthAccount()?.address ?? "");
  var address = shortBlockChainAddress(hynAddress);
  return "$walletName ($address)";
}

//==================================Atlas Message Begin==============================================

class ConfirmCreateAtlasNodeMessage implements AtlasMessage {
  final CreateAtlasEntity entity;
  ConfirmCreateAtlasNodeMessage({this.entity});

  @override
  Future<dynamic> action(String password) async {
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
    return ConfirmInfoDescription(
      title: "确认创建Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
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
  Future<dynamic> action(String password) async {
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
    return ConfirmInfoDescription(
      title: "确认编辑Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Atlas节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.000021",
    );
  }
}

class ConfirmAtlasReceiveAwardMessage implements AtlasMessage {
  final String nodeId;
  final String map3Address;
  final String atlasAddress;
  ConfirmAtlasReceiveAwardMessage({this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasReceiveReward(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().getAtlasReward(rawTx);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_RECEIVE_AWARD;

  @override
  ConfirmInfoDescription get description {
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
  Future<dynamic> action(String password) async {
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
    return ConfirmInfoDescription(
      title: "激活节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Atlas链",
      toDetail: "",
      fee: "0.000021",
    );
  }
}

class ConfirmAtlasStakeMessage implements AtlasMessage {
  final String nodeId;
  final String map3Address;
  final String atlasAddress;
  ConfirmAtlasStakeMessage({this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasStake(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postPledgeAtlas(rawTx);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_STAKE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "抵押Atlas节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Atlas节点",
      toDetail: "节点号:$nodeId",
      fee: "0.000021",
    );
  }
}

class ConfirmAtlasUnStakeMessage implements AtlasMessage {
  final String nodeId;
  final String map3Address;
  final String atlasAddress;
  ConfirmAtlasUnStakeMessage({this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasUnStake(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postPledgeAtlas(rawTx);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_STAKE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "撤销抵押",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
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
  Future<dynamic> action(String password) async {
    try {
      print("[object] --> 2");

      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transCreateMap3Node(this.entity, password, wallet);
      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().postCreateMap3Node(this.entity);
      print("[Confirm] rawTx:$rawTx, txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.nodeId;
    } catch (e) {
      print(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CREATE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "确认创建节点",
      amountDirection: "-",
      amount: entity.payload.staking,
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
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
  Future<dynamic> action(String password) async {
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
    return ConfirmInfoDescription(
      title: "确认编辑节点",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Map3节点",
      toDetail: "节点号:${entity.payload.nodeId}",
      fee: "0.000021",
    );
  }
}

class ConfirmPreEditMap3NodeMessage implements AtlasMessage {
  final bool autoRenew;
  final String feeRate;
  final String map3NodeAddress;

  ConfirmPreEditMap3NodeMessage({
    this.autoRenew,
    this.feeRate,
    this.map3NodeAddress,
  });

  @override
  Future<dynamic> action(String password) async {
    print("[ConfirmPreEditMap3NodeMessage] action:$password");

    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transPreEditMap3Node(
        password,
        wallet,
        this.autoRenew,
        feeRate,
        map3NodeAddress,
      );
      return rawTx.isNotEmpty;
    } catch (e) {
      print(e);
      LogUtil.toastException(e);
    }
    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_PRE_EDIT;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "确认修改预设",
      amountDirection: "",
      amount: "0",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
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
  Future<dynamic> action(String password) async {
    print("[Confirm] exit");

    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transTerminateMap3Node(password, this.map3NodeAddress, wallet);
      this.entity.rawTx = rawTx;
      print("[Confirm] rawTx:$rawTx");

      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      print("[Confirm] rawTx:$rawTx, txHashEntity:${txHashEntity.txHash}");
      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      print(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_TERMINAL;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "确认终止节点",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "节点号:${entity?.payload?.userIdentity ?? ""}",
      amount: "0",
      toName: "钱包",
      toDetail: _walletAddressAndName,
      fee: "0.000021",
    );
  }
}

class ConfirmCancelMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  final String amount;
  ConfirmCancelMap3NodeMessage({this.entity, this.map3NodeAddress, this.amount});

  @override
  Future<dynamic> action(String password) async {
    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transUnMicroMap3Node(this.amount, password, this.map3NodeAddress, wallet);
      this.entity.rawTx = rawTx;

      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      print("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      LogUtil.toastException(e);
      print(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CANCEL;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "确认撤销",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "节点号:${entity?.payload?.userIdentity ?? ""}",
      amount: amount ?? "0",
      toName: "钱包",
      toDetail: _walletAddressAndName,
      fee: "0.000021",
    );
  }
}

class ConfirmDelegateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  final String amount;
  final String pendingAmount;
  ConfirmDelegateMap3NodeMessage({this.entity, this.map3NodeAddress, this.amount, this.pendingAmount});

  @override
  Future<dynamic> action(String password) async {
    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transMicroMap3Node(this.amount, password, this.map3NodeAddress, wallet);

      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      print("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return [amount, pendingAmount];
    } catch (e) {
      print("e:$e");
      // todo: "code":-10000,"msg":"Unknown error","data":null,"subMsg":"-32000 | delegation amount too small"}
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_DELEGATE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "确认抵押节点",
      amountDirection: "-",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Map3节点",
      toDetail: "节点号:${entity?.payload?.userIdentity ?? ""}",
      amount: amount ?? "0",
      fee: "0.000021",
    );
  }
}

class ConfirmCollectMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String amount;
  final List<String> addressList;
  ConfirmCollectMap3NodeMessage({
    this.entity,
    this.amount,
    this.addressList,
  });

  @override
  Future<dynamic> action(String password) async {
    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transCollectMap3Node(password, wallet);

      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().getMap3Reward(this.entity);
      print("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      print(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_COLLECT;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "提取奖励",
      amountDirection: "+",
      fromName: "Map3节点",
      fromDetail: "",
      amount: this.amount,
      toName: "钱包",
      toDetail: _walletAddressAndName,
      fee: "0.000021",
      addressList: this.addressList,
    );
  }
}

class ConfirmDivideMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  ConfirmDivideMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<dynamic> action(String password) async {
    // var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
//    var rawTx =
//        await HYNApi.transMicroMap3Node(this.entity.amount, password, this.entity.to, this.map3NodeAddress, wallet);
//    this.entity.rawTx = rawTx;

    TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
    print("[Confirm] txHashEntity:${txHashEntity.txHash}");

    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_ADD;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: "节点分裂",
      amountDirection: "-",
      fromName: "钱包",
      fromDetail: _walletAddressAndName,
      toName: "Map3节点",
      toDetail: "节点号:${entity?.payload?.userIdentity ?? ""}",
      amount: "0",
      fee: "0.000021",
    );
  }
}
