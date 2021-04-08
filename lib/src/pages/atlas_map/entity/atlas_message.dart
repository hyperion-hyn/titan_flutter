import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
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
  var hynAddress =
      WalletUtil.ethAddressToBech32Address(activatedWallet?.wallet?.getEthAccount()?.address ?? "");
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
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
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
      fee: "0.0001",
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
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
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
      fee: "0.0001",
    );
  }
}

class ConfirmAtlasReceiveAwardMessage implements AtlasMessage {
  final String nodeName;
  final String nodeId;
  final String map3Address;
  final String atlasAddress;

  ConfirmAtlasReceiveAwardMessage(
      {this.nodeName, this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasReceiveReward(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().getAtlasReward(rawTx);
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_RECEIVE_AWARD;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).action_atals_receive_award,
      amountDirection: "+",
      amount: "0",
      fromName: nodeName ?? S.of(Keys.rootKey.currentContext).atlas_node,
      fromDetail: S.of(Keys.rootKey.currentContext).node_num_and_node_id(nodeId),
      toName: S.of(Keys.rootKey.currentContext).map3_node,
      toDetail: "",
      fee: "0.0001",
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
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_ACTIVE_NODE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).active_node,
      amountDirection: "",
      amount: "0",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: S.of(Keys.rootKey.currentContext).atlas_chain,
      toDetail: "",
      fee: "0.0001",
    );
  }
}

class ConfirmAtlasStakeMessage implements AtlasMessage {
  final String nodeName;
  final String nodeId;
  final String map3Address;
  final String atlasAddress;

  ConfirmAtlasStakeMessage({this.nodeName, this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasStake(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postPledgeAtlas(rawTx);
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_STAKE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).staking_atlas_node,
      amountDirection: "",
      amount: "0",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: nodeName ?? S.of(Keys.rootKey.currentContext).atlas_node,
      toDetail: S.of(Keys.rootKey.currentContext).node_num_and_node_id(nodeId),
      fee: "0.0001",
    );
  }
}

class ConfirmAtlasUnStakeMessage implements AtlasMessage {
  final String nodeName;
  final String nodeId;
  final String map3Address;
  final String atlasAddress;

  ConfirmAtlasUnStakeMessage({this.nodeName, this.nodeId, this.map3Address, this.atlasAddress});

  @override
  Future<dynamic> action(String password) async {
    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
    var rawTx = await HYNApi.transAtlasUnStake(map3Address, atlasAddress, password, wallet);

    TxHashEntity txHashEntity = await AtlasApi().postPledgeAtlas(rawTx);
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");
    return txHashEntity.txHash.isNotEmpty;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.ATLAS_CANCEL_STAKE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).cancel_delegate,
      amountDirection: "",
      amount: "0",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: nodeName ?? S.of(Keys.rootKey.currentContext).atlas_node,
      toDetail: S.of(Keys.rootKey.currentContext).node_num_and_node_id(nodeId),
      fee: "0.0001",
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
      LogUtil.printMessage("[object] --> 2");

      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transCreateMap3Node(this.entity, password, wallet);
      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().postCreateMap3Node(this.entity);
      LogUtil.printMessage("[Confirm] rawTx:$rawTx, txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.nodeId;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CREATE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_create_node,
      amountDirection: "-",
      amount: entity.payload.staking,
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: S.of(Keys.rootKey.currentContext).map3_node,
      toDetail: S.of(Keys.rootKey.currentContext).node_num_and_node_id(entity.payload.nodeId),
      fee: "0.0001",
    );
  }
}

class ConfirmEditMap3NodeMessage implements AtlasMessage {
  final CreateMap3Entity entity;
  final String map3NodeAddress;

  ConfirmEditMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<dynamic> action(String password) async {
    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx =
          await HYNApi.transEditMap3Node(this.entity, password, this.map3NodeAddress, wallet);
      this.entity.rawTx = rawTx;

      var uploadRawTx = '[ConfirmEditMap3NodeMessage] wallet:${wallet.toJson()}, rawTx:$rawTx';
      LogUtil.printMessage(uploadRawTx);
      LogUtil.uploadException("[ConfirmEditMap3NodeMessage] action, uploadRawTx", uploadRawTx);

      TxHashEntity txHashEntity = await AtlasApi().postEditMap3Node(this.entity);
      LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");

      var uploadTxHashEntity = '[ConfirmEditMap3NodeMessage] txHashEntity:${txHashEntity.toJson()}';
      LogUtil.printMessage(uploadTxHashEntity);
      LogUtil.uploadException(
          "[ConfirmEditMap3NodeMessage] action, uploadTxHashEntity", uploadTxHashEntity);

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_EDIT;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_edit_node,
      amountDirection: "",
      amount: "0",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: S.of(Keys.rootKey.currentContext).map3_node,
      toDetail: entity.payload.nodeId == null
          ? ''
          : S.of(Keys.rootKey.currentContext).node_num_and_node_id(entity.payload.nodeId),
      fee: "0.0001",
    );
  }
}

class ConfirmPreEditMap3NodeMessage implements AtlasMessage {
  final bool autoRenew;
  final String feeRate;
  final String map3NodeAddress;
  final String map3NodeName;
  int nonce;

  ConfirmPreEditMap3NodeMessage({
    this.autoRenew,
    this.feeRate,
    this.map3NodeAddress,
    this.map3NodeName,
    this.nonce,
  });

  @override
  Future<dynamic> action(String password) async {
    LogUtil.printMessage("[ConfirmPreEditMap3NodeMessage] action:$password, nonce:$nonce");

    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transPreEditMap3Node(
        password,
        wallet,
        this.autoRenew,
        feeRate,
        map3NodeAddress,
        nonce,
      );

      var uploadPreMsgRawText =
          '[ConfirmPreEditMap3NodeMessage] wallet:${wallet.toJson()}, rawTx:$rawTx';
      LogUtil.printMessage(uploadPreMsgRawText);
      LogUtil.uploadException(
          "[ConfirmPreEditMap3NodeMessage] action, uploadTxHashEntity", uploadPreMsgRawText);

      return rawTx.isNotEmpty;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }
    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_PRE_EDIT;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_modify_preset,
      amountDirection: "",
      amount: "0",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: S.of(Keys.rootKey.currentContext).map3_node,
      toDetail: "${this.map3NodeName ?? ""}",
      fee: "0.0001",
    );
  }
}

class ConfirmTerminateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;

  ConfirmTerminateMap3NodeMessage({this.entity, this.map3NodeAddress});

  @override
  Future<dynamic> action(String password) async {
    LogUtil.printMessage("[Confirm] exit");

    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx = await HYNApi.transTerminateMap3Node(password, this.map3NodeAddress, wallet);
      this.entity.rawTx = rawTx;
      LogUtil.printMessage("[Confirm] rawTx:$rawTx");

      var uploadRawText =
          '[ConfirmTerminateMap3NodeMessage] wallet:${wallet.toJson()}, rawTx:$rawTx';
      LogUtil.printMessage(uploadRawText);
      LogUtil.uploadException(
          "[ConfirmTerminateMap3NodeMessage] action, uploadTxHashEntity", uploadRawText);

      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      LogUtil.printMessage("[Confirm] rawTx:$rawTx, txHashEntity:${txHashEntity.txHash}");
      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_TERMINAL;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_termination_node,
      amountDirection: "+",
      fromName: S.of(Keys.rootKey.currentContext).map3_node,
      fromDetail: S
          .of(Keys.rootKey.currentContext)
          .node_num_and_node_id(entity?.payload?.userIdentity ?? ""),
      amount: "0",
      toName: S.of(Keys.rootKey.currentContext).wallet,
      toDetail: _walletAddressAndName,
      fee: "0.0001",
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
      var rawTx =
          await HYNApi.transUnMicroMap3Node(this.amount, password, this.map3NodeAddress, wallet);
      this.entity.rawTx = rawTx;

      var uploadRawText = '[ConfirmCancelMap3NodeMessage] wallet:${wallet.toJson()}, rawTx:$rawTx';
      LogUtil.printMessage(uploadRawText);
      LogUtil.uploadException(
          "[ConfirmCancelMap3NodeMessage] action, uploadTxHashEntity", uploadRawText);

      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_CANCEL;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_cancel,
      amountDirection: "+",
      fromName: S.of(Keys.rootKey.currentContext).map3_node,
      fromDetail: S
          .of(Keys.rootKey.currentContext)
          .node_num_and_node_id(entity?.payload?.userIdentity ?? ""),
      amount: amount ?? "0",
      toName: S.of(Keys.rootKey.currentContext).wallet,
      toDetail: _walletAddressAndName,
      fee: "0.0001",
    );
  }
}

class ConfirmDelegateMap3NodeMessage implements AtlasMessage {
  final PledgeMap3Entity entity;
  final String map3NodeAddress;
  final String amount;
  final String pendingAmount;
  final String nodeId;

  ConfirmDelegateMap3NodeMessage({
    this.entity,
    this.map3NodeAddress,
    this.amount,
    this.pendingAmount,
    this.nodeId,
  });

  @override
  Future<dynamic> action(String password) async {
    LogUtil.printMessage("[Confirm] this.amount:${this.amount}");

    try {
      var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet;
      var rawTx =
          await HYNApi.transMicroMap3Node(this.amount, password, this.map3NodeAddress, wallet);
      LogUtil.printMessage("[Confirm] rawTx:${rawTx}");

      this.entity.rawTx = rawTx;
      TxHashEntity txHashEntity = await AtlasApi().postPledgeMap3(this.entity);
      LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return [amount, pendingAmount];
    } catch (e, stack) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
      print(stack);

      ///  "code":-10000,"msg":"Unknown error","data":null,"subMsg":"-32000 | delegation amount too small"}
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_DELEGATE;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).confirm_mortgage_node,
      amountDirection: "-",
      fromName: S.of(Keys.rootKey.currentContext).wallet,
      fromDetail: _walletAddressAndName,
      toName: S.of(Keys.rootKey.currentContext).map3_node,
      toDetail: S.of(Keys.rootKey.currentContext).node_num_and_node_id(nodeId ?? ""),
      amount: amount ?? "0",
      fee: "0.0001",
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

      var uploadRawText = '[ConfirmCollectMap3NodeMessage] wallet:${wallet.toJson()}, rawTx:$rawTx';
      LogUtil.printMessage(uploadRawText);
      LogUtil.uploadException(
          "[ConfirmCollectMap3NodeMessage] action, uploadTxHashEntity", uploadRawText);

      TxHashEntity txHashEntity = await AtlasApi().getMap3Reward(this.entity);
      LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");

      return txHashEntity.txHash.isNotEmpty;
    } catch (e) {
      LogUtil.printMessage(e);
      LogUtil.toastException(e);
    }

    return false;
  }

  @override
  Map3NodeActionEvent get type => Map3NodeActionEvent.MAP3_COLLECT;

  @override
  ConfirmInfoDescription get description {
    return ConfirmInfoDescription(
      title: S.of(Keys.rootKey.currentContext).action_atals_receive_award,
      amountDirection: "+",
      fromName: S.of(Keys.rootKey.currentContext).map3_node,
      fromDetail: "",
      amount: this.amount,
      toName: S.of(Keys.rootKey.currentContext).wallet,
      toDetail: _walletAddressAndName,
      fee: "0.0001",
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
    LogUtil.printMessage("[Confirm] txHashEntity:${txHashEntity.txHash}");

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
      fee: "0.0001",
    );
  }
}

class TransactionStatus {
  static const nil = 0;
  static const pending = 1;
  static const pending_for_receipt = 2;
  static const success = 3;
  static const fail = 4;
  static const droppedAndReplaced = 5;
}
