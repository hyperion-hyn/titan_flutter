import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/contract_transaction_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_default_entity.dart';

import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/pages/node/model/transaction_history_entity.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import 'node_http.dart';

class NodeApi {
  Map<String, dynamic> getOptionHeader({hasLang = false, hasAddress = false}) {
    if (!hasLang && !hasAddress) {
      return null;
    }
    Map<String, dynamic> headMap = Map();

    headMap.putIfAbsent("appSource", () => Config.APP_SOURCE);

    var activeWalletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    if (hasAddress && activeWalletVo != null) {
      headMap.putIfAbsent("Address", () => activeWalletVo.wallet.getEthAccount().address);
    }

    if (hasLang) {
      var language = SettingInheritedModel.of(Keys.rootKey.currentContext).netLanguageCode;
      headMap.putIfAbsent("Lang", () => language);
    }

    return headMap;
  }

  Future<List<ContractNodeItem>> getMyCreateNodeContract({int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/my-create",
        EntityFactory<List<ContractNodeItem>>(
            (list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
  }

  Future<List<ContractNodeItem>> getMyJoinNodeContract({int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/my-join",
        EntityFactory<List<ContractNodeItem>>(
            (list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
  }

  Future<ContractDetailItem> getContractDetail(int contractId) async {
    return await NodeHttpCore.instance.getEntity("/delegations/instance/$contractId",
        EntityFactory<ContractDetailItem>((data) => ContractDetailItem.fromJson(data)),
        options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
  }

  Future<List<ContractDelegatorItem>> getContractDelegator(int contractNodeItemId, {int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/instance/$contractNodeItemId/delegators",
        EntityFactory<List<ContractDelegatorItem>>(
            (list) => (list as List).map((item) => ContractDelegatorItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
  }

  Future<List<ContractDelegateRecordItem>> getContractDelegateRecord(int contractNodeItemId, {int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/instance/$contractNodeItemId/delegate_record",
        EntityFactory<List<ContractDelegateRecordItem>>(
            (list) => (list as List).map((item) => ContractDelegateRecordItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
  }

  Future<List<NodeItem>> getContractList(int page) async {
    var contractsList =
        await NodeHttpCore.instance.getEntity("/contracts/list?page=$page", EntityFactory<List<NodeItem>>((data) {
      return (data as List).map((dataItem) => NodeItem.fromJson(dataItem)).toList();
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsList;
  }

  Future<List<NodeProviderEntity>> getNodeProviderList() async {
    var nodeProviderList =
        await NodeHttpCore.instance.getEntity("/nodes/providers", EntityFactory<List<NodeProviderEntity>>((data) {
      return (data as List).map((dataItem) => NodeProviderEntity.fromJson(dataItem)).toList();
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return nodeProviderList;
  }

  Future<ContractNodeItem> getContractItem(String contractId) async {
    var nodeItem =
        await NodeHttpCore.instance.getEntity("/contracts/detail/$contractId", EntityFactory<NodeItem>((data) {
      return NodeItem.fromJson(data);
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return ContractNodeItem.onlyNodeItem(nodeItem);
  }

  Future<ContractNodeItem> getContractInstanceItem(String contractId) async {
    var contractsItem =
        await NodeHttpCore.instance.getEntity("/instances/detail/$contractId", EntityFactory<ContractNodeItem>((data) {
      return ContractNodeItem.fromJson(data);
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsItem;
  }
 
  Future<ContractNodeItem> startContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet,
      String password, int gasPrice, String contractId, StartJoinInstance startJoinInstance, Decimal amount, {bool isRenew = false}) async {

    var wallet = activatedWallet.wallet;
//    var maxStakingAmount = 1000000; //一百万
//    var myStaking = amount;
    var hynAssetToken = wallet.getHynToken();
    var hynErc20ContractAddress = hynAssetToken?.contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;
    var walletHynAddress = wallet.getEthAccount().address;
    var walletName = wallet.keystore.name;

    var nodeKey =
        await NodeHttpCore.instance.getEntity("/nodekey/generate", EntityFactory<Map<String, dynamic>>((data) {
      return data;
    }), options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
    int durationType = contractNodeItem.contract.durationType; //0: 1M， 1: 3M， 2: 6M
    var firstHalfPubKey = nodeKey["firstHalfPubKey"];
    var secondHalfPubKey = nodeKey["secondHalfPubKey"];
    var publicKey = nodeKey["publicKey"];

    final client = WalletUtil.getWeb3Client();
    var count =
        await client.getTransactionCount(EthereumAddress.fromHex(walletHynAddress));

    //approve
    print('approve result: $count');
    var approveHex = await wallet.sendApproveErc20Token(
        contractAddress: hynErc20ContractAddress,
        approveToAddress: approveToAddress,
        amount: ConvertTokenUnit.decimalToWei(amount),
        password: password,
        gasPrice: BigInt.from(gasPrice),
        gasLimit: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.erc20ApproveGasLimit,
        nonce: count);
    print('approve result: $approveHex， durationType:${durationType}');

    //create
    var createMap3Hex = await wallet.sendCreateMap3Node(
      stakingAmount: ConvertTokenUnit.decimalToWei(amount),
      type: durationType,
      firstHalfPubKey: firstHalfPubKey,
      secondHalfPubKey: secondHalfPubKey,
      gasPrice: BigInt.from(gasPrice),
      gasLimit: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.createMap3NodeGasLimit,
      password: password,
      nonce: count + 1,
    );
    print('createMap3Hex is: $createMap3Hex');

    if (isRenew) {
      return contractNodeItem;
    }
    return await postStartDefaultInstance(contractNodeItem.contract.id, walletHynAddress,walletName,amount.toDouble(),publicKey,createMap3Hex
        ,startJoinInstance.provider,startJoinInstance.region);
  }

  Future<String> joinContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, createNodeWalletAddress, String contractId, Decimal amount) async {
    var wallet = activatedWallet.wallet;

    var myStaking = amount;
    var ethAccount = wallet.getEthAccount();
    var hynErc20ContractAddress = wallet.getEthAccount().contractAssetTokens[0].contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;
    var walletHynAddress = wallet.getEthAccount().address;
    var walletName = wallet.keystore.name;

    final client = WalletUtil.getWeb3Client();
//    var count =
//        await client.getTransactionCount(EthereumAddress.fromHex(ethAccount.address));
    int nonce = await wallet.getCurrentWalletNonce();

    //approve
    var approveHex = await wallet.sendApproveErc20Token(
      contractAddress: hynErc20ContractAddress,
      approveToAddress: approveToAddress,
      amount: ConvertTokenUnit.decimalToWei(myStaking),
      password: password,
      gasPrice: BigInt.from(gasPrice),
      gasLimit: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.erc20ApproveGasLimit,
      nonce: nonce,
      isStore: true
    );
    print('approveHex is: $approveHex');

    var joinHex = await wallet.sendDelegateMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      stakingAmount: ConvertTokenUnit.decimalToWei(myStaking),
      gasPrice: BigInt.from(gasPrice),
      gasLimit: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext).systemConfigEntity.delegateMap3NodeGasLimit,
      password: password,
      nonce: nonce + 1,
    );
    print('joinHex is: $joinHex');

    await postJoinDefaultInstance(contractNodeItem.id, walletHynAddress, walletName, amount.toDouble(), joinHex);

    return "success";
  }

  Future<NodePageEntityVo> getNodePageEntityVo() async {
    var nodeHeadEntity = await NodeHttpCore.instance.getEntity("/nodes/intro", EntityFactory<NodeHeadEntity>((data) {
      return NodeHeadEntity.fromJson(data);
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    var pendingList = await getContractPendingList(0);

    return NodePageEntityVo(nodeHeadEntity, pendingList);
  }

  Future<List<ContractNodeItem>> getContractPendingList(int page) async {
    var contractsList = await NodeHttpCore.instance.getEntity("/instances/pending?page=$page",
        EntityFactory<List<ContractNodeItem>>((data) {
      return (data as List).map((dataItem) => ContractNodeItem.fromJson(dataItem)).toList();
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsList;
  }

  Future<List<ContractNodeItem>> getContractActiveList([int page = 0]) async {
    var contractsList = await NodeHttpCore.instance.getEntity("/instances/active?page=$page",
        EntityFactory<List<ContractNodeItem>>((data) {
          return (data as List).map((dataItem) => ContractNodeItem.fromJson(dataItem)).toList();
        }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsList;
  }

  Future postWallets(WalletVo _activatedWalletVo) async {
    if (_activatedWalletVo?.wallet != null &&
        _activatedWalletVo?.wallet?.getEthAccount() != null &&
        _activatedWalletVo.wallet.keystore != null) {
      String postData =
          "{\"address\":\"${_activatedWalletVo.wallet.getEthAccount()?.address}\",\"name\":\"${_activatedWalletVo.wallet.keystore?.name}\"}";

      NodeHttpCore.instance.post("wallets/", data: postData, options: RequestOptions(contentType: "application/json"));
    }
  }

  @deprecated
  Future postJoinContractTransaction(ContractTransactionEntity _entity, String contractId) async {
    NodeHttpCore.instance.post("/instances/delegate/$contractId",
        data: _entity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  @deprecated
  Future postCreateContractTransaction(ContractTransactionEntity _entity, String contractId) async {
    NodeHttpCore.instance.post("/contracts/create/$contractId",
        data: _entity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future<ContractNodeItem> postStartDefaultInstance(
    int contractId,
    String address,
    String name,
    double amount,
    String publicKey,
    String txHash,
    String nodeProvider,
    String nodeRegion,
  ) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(address, txHash,
        name: name, amount: amount, publicKey: publicKey, nodeProvider: nodeProvider, nodeRegion: nodeRegion);
    print("[api] postStart , nodeDefaultEntity.toJson():${nodeDefaultEntity.toJson()}");

    //NodeHttpCore.instance.post("contracts/precreate/$contractId", data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));

    return NodeHttpCore.instance.postEntity(
        "contracts/precreate/$contractId",
        EntityFactory<ContractNodeItem>(
          (json) => ContractNodeItem.fromJson(json),
        ),
        data: nodeDefaultEntity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  Future postJoinDefaultInstance(
      int contractInstanceId, String address, String name, double amount, String txHash) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(
      address,
      txHash,
      name: name,
      amount: amount,
      shareKey: MemoryCache.shareKey,
    );
    NodeHttpCore.instance.post("instances/predelegate/$contractInstanceId",
        data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future postWithdrawDefaultInstance(int contractInstanceId, String address, String txHash) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(
      address,
      txHash,
    );
    NodeHttpCore.instance.post("instances/precollect/$contractInstanceId",
        data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future<String> withdrawContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, int gasLimit) async {
    var wallet = activatedWallet.wallet;
    var createNodeWalletAddress = contractNodeItem.owner;
    final client = WalletUtil.getWeb3Client();
    var address = wallet.getEthAccount().address;
    var nonce = await client.getTransactionCount(EthereumAddress.fromHex(address));

    var collectHex = await wallet.sendCollectMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      gasPrice: BigInt.from(gasPrice),
      gasLimit: gasLimit,
      password: password,
      nonce: nonce,
    );
    print('collectHex is: $collectHex');

    await postWithdrawDefaultInstance(contractNodeItem.id, address, collectHex);

    return "success";
  }

  Future<bool> checkIsDelegatedContractInstance(int contractId) async {
    var isDelegated = await NodeHttpCore.instance.getEntity("/delegations/instance/$contractId/isdelegated",
        EntityFactory<bool>((data) {
      return data;
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true, hasAddress: true)));

    return isDelegated;
  }

  Future<bool> checkIsUserCreatableContractInstance() async {
    var isCreate = await NodeHttpCore.instance.getEntity("/contracts/isUserCreatable", EntityFactory<bool>((data) {
      return data;
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true, hasAddress: true)));

    return isCreate;
  }
}
