import 'dart:convert';

import 'package:dio/dio.dart';
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

  Map<String,dynamic> getOptionHeader({hasLang = false,hasAddress = false}){
    if(!hasLang && !hasAddress){
      return null;
    }
    Map<String,dynamic> headMap = Map();

    headMap.putIfAbsent("appSource", ()=> "TITAN");

    if(hasAddress){
      var activeWalletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      headMap.putIfAbsent("Address", () => activeWalletVo.wallet.getEthAccount().address);
    }
    if(hasLang){
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
        params: {"page": page},options: RequestOptions(headers: getOptionHeader(hasAddress:true,hasLang: true)));
  }

  Future<List<ContractNodeItem>> getMyJoinNodeContract({int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/my-join",
        EntityFactory<List<ContractNodeItem>>(
            (list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        params: {"page": page}
        ,options: RequestOptions(headers: getOptionHeader(hasAddress:true,hasLang: true)));
  }

  Future<ContractDetailItem> getContractDetail(int contractId) async {
    return await NodeHttpCore.instance.getEntity("/delegations/instance/$contractId",
        EntityFactory<ContractDetailItem>((data) => ContractDetailItem.fromJson(data))
        ,options: RequestOptions(headers: getOptionHeader(hasAddress:true,hasLang: true)));
  }

  Future<List<ContractDelegatorItem>> getContractDelegator(int contractNodeItemId, {int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/instance/$contractNodeItemId/delegators",
        EntityFactory<List<ContractDelegatorItem>>(
            (list) => (list as List).map((item) => ContractDelegatorItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress:true,hasLang: true)));
  }

  Future<List<ContractDelegateRecordItem>> getContractDelegateRecord(int contractNodeItemId, {int page = 0}) async {
    return await NodeHttpCore.instance.getEntity(
        "/delegations/instance/$contractNodeItemId/delegate_record",
        EntityFactory<List<ContractDelegateRecordItem>>(
                (list) => (list as List).map((item) => ContractDelegateRecordItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: getOptionHeader(hasAddress:true,hasLang: true)));
  }

  Future<List<NodeItem>> getContractList(int page) async {
    var contractsList =
        await NodeHttpCore.instance.getEntity("/contracts/list?page=$page", EntityFactory<List<NodeItem>>((data) {
      return (data as List).map((dataItem) => NodeItem.fromJson(dataItem)).toList();
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsList;
  }

  Future<List<NodeProviderEntity>> getNodeProviderList() async {
    var nodeProviderList =
    await NodeHttpCore.instance.getEntity("/nodes/providers", EntityFactory<List<NodeProviderEntity>>((data) {
      return (data as List).map((dataItem) => NodeProviderEntity.fromJson(dataItem)).toList();
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return nodeProviderList;
  }

  Future<ContractNodeItem> getContractItem(String contractId) async {
    var nodeItem = await NodeHttpCore.instance.getEntity("/contracts/detail/$contractId", EntityFactory<NodeItem>((data) {
      return NodeItem.fromJson(data);
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return ContractNodeItem.onlyNodeItem(nodeItem);
  }

  Future<ContractNodeItem> getContractInstanceItem(String contractId) async {
    var contractsItem =
        await NodeHttpCore.instance.getEntity("/instances/detail/$contractId", EntityFactory<ContractNodeItem>((data) {
      return ContractNodeItem.fromJson(data);
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return contractsItem;
  }

  Future<String> startContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, String contractId, StartJoinInstance startJoinInstance,double amount) async {
    var wallet = activatedWallet.wallet;
//    var maxStakingAmount = 1000000; //一百万
    var myStaking = amount;
    var hynAssetToken = wallet.getHynToken();
    var hynErc20ContractAddress = hynAssetToken?.contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;
    var walletHynAddress = wallet.getEthAccount().address;
    var walletName = wallet.keystore.name;
    var pubKey = await TitanPlugin.getPublicKey();

    var nodeKey = await NodeHttpCore.instance.getEntity("/nodekey/generate", EntityFactory<Map<String, dynamic>>((data) {
      return data;
    }),options: RequestOptions(headers: getOptionHeader(hasAddress: true, hasLang: true)));
    int durationType = contractNodeItem.contract.durationType; //0: 1M， 1: 3M， 2: 6M

    final client = WalletUtil.getWeb3Client();
    var count = await client.getTransactionCount(EthereumAddress.fromHex(walletHynAddress), atBlock: BlockNum.pending());

    //approve
    print('approve result: $count');
    var approveHex = await wallet.sendApproveErc20Token(
        contractAddress: hynErc20ContractAddress,
        approveToAddress: approveToAddress,
        amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
        password: password,
        gasPrice: BigInt.from(gasPrice),
        gasLimit: EthereumConst.ERC20_APPROVE_GAS_LIMIT,
        nonce: count);
    print('approve result: $approveHex， durationType:${durationType}');
    var state = await postTransactionHistory(walletHynAddress, contractNodeItem.id, approveHex
        , transactionHistoryAction2String(TransactionHistoryAction.APPROVE), amount);
    print('[create] contractNodeItem.amountDelegation:${contractNodeItem.amountDelegation}, state:${state}');

    //create
    var createMap3Hex = await wallet.sendCreateMap3Node(
      stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      type: durationType,
      firstHalfPubKey: nodeKey["firstHalfPubKey"],
      secondHalfPubKey: nodeKey["secondHalfPubKey"],
      gasPrice: BigInt.from(gasPrice),
      gasLimit: EthereumConst.CREATE_MAP3_NODE_GAS_LIMIT,
      password: password,
      nonce: count + 1,
    );
    print('createMap3Hex is: $createMap3Hex');

    /*var pubKey = await TitanPlugin.getPublicKey();
    var name = wallet.keystore.name;
    var address = walletHynAddress;
    ContractTransactionEntity _entity = ContractTransactionEntity(
      address,
      name,
      amount.toInt(),
      pubKey,
      createMap3Hex,
    );
    await postCreateContractTransaction(_entity, contractId);*/
    await postTransactionHistory(walletHynAddress, contractNodeItem.id, createMap3Hex
        , transactionHistoryAction2String(TransactionHistoryAction.CREATE_NODE), amount);

    await postStartDefaultInstance(contractNodeItem.contract.id, walletHynAddress,walletName,amount,pubKey,createMap3Hex
        ,startJoinInstance.provider,startJoinInstance.region);
//    startJoinInstance.txHash = createMap3Hex;
//    startJoinInstance.publicKey = nodeKey["publicKey"];
    String postData = json.encode(startJoinInstance.toJson());
    print("startContractInstance = $postData");
    var data = await NodeHttpCore.instance
        .post("node-provider/", data: postData, options: RequestOptions(contentType: "application/json"));
    return data['msg'];
  }

  Future<String> joinContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, createNodeWalletAddress, String contractId, double amount) async {
    var wallet = activatedWallet.wallet;

    var myStaking = amount;
    var ethAccount = wallet.getEthAccount();
    var hynErc20ContractAddress = wallet.getEthAccount().contractAssetTokens[0].contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;
    var walletHynAddress = wallet.getEthAccount().address;
    var walletName = wallet.keystore.name;

    final client = WalletUtil.getWeb3Client();
    var count =
        await client.getTransactionCount(EthereumAddress.fromHex(ethAccount.address), atBlock: BlockNum.pending());

    //approve
    var approveHex = await wallet.sendApproveErc20Token(
      contractAddress: hynErc20ContractAddress,
      approveToAddress: approveToAddress,
      amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      password: password,
      gasPrice: BigInt.from(gasPrice),
      gasLimit: EthereumConst.ERC20_APPROVE_GAS_LIMIT,
      nonce: count,
    );
    print('approveHex is: $approveHex');
    await postTransactionHistory(wallet.getEthAccount().address, contractNodeItem.id, approveHex
        , transactionHistoryAction2String(TransactionHistoryAction.APPROVE), amount);

    var joinHex = await wallet.sendDelegateMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      gasPrice: BigInt.from(gasPrice),
      gasLimit: EthereumConst.DELEGATE_MAP3_NODE_GAS_LIMIT,
      password: password,
      nonce: count + 1,
    );
    print('joinHex is: $joinHex');
    await postTransactionHistory(wallet.getEthAccount().address,contractNodeItem.id, joinHex
        , transactionHistoryAction2String(TransactionHistoryAction.DELEGATE),amount);

    await postJoinDefaultInstance(contractNodeItem.id, walletHynAddress, walletName, amount, joinHex);
    /*var pubKey = await TitanPlugin.getPublicKey();
    var name = wallet.keystore.name;
    var address = wallet.getEthAccount().address;
    ContractTransactionEntity _entity = ContractTransactionEntity(
      address,
      name,
      amount.toInt(),
      pubKey,
      joinHex,
    );
    await postJoinContractTransaction(_entity, contractId);*/

//    startJoinInstance.txHash = joinHex;
//    String postData = json.encode(startJoinInstance.toJson());
//    print("joinContractInstance = $postData");
//    var data = await NodeHttpCore.instance.post("instances/delegate/$contractId",
//        data: postData, options: RequestOptions(contentType: "application/json"));
//    return data['msg'];
    return "success";
  }

  Future<NodePageEntityVo> getNodePageEntityVo() async {
    var nodeHeadEntity = await NodeHttpCore.instance.getEntity("/nodes/intro", EntityFactory<NodeHeadEntity>((data) {
      return NodeHeadEntity.fromJson(data);
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    var pendingList = await getContractPendingList(0);

    return NodePageEntityVo(nodeHeadEntity, pendingList);
  }

  Future<List<ContractNodeItem>> getContractPendingList(int page) async {
    var contractsList =
        await NodeHttpCore.instance.getEntity("/instances/pending?page=$page", EntityFactory<List<ContractNodeItem>>((data) {
      return (data as List).map((dataItem) => ContractNodeItem.fromJson(dataItem)).toList();
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true)));

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
      NodeHttpCore.instance.post("/instances/delegate/$contractId", data: _entity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  @deprecated
  Future postCreateContractTransaction(ContractTransactionEntity _entity, String contractId) async {
    NodeHttpCore.instance.post("/contracts/create/$contractId", data: _entity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future postTransactionHistory(String address, int instanceId,String txhash, String operaType, double amount) async {
    print('[Transaction]  amount:${amount}');

    TransactionHistoryEntity historyEntity = TransactionHistoryEntity(
      address,
      instanceId,
      txhash,
      operaType,
      amount.toInt(),
      MemoryCache.shareKey
    );
    print('[Transaction]  data:${historyEntity.toJson()}');
    NodeHttpCore.instance.post("eth-transaction-history/", data: historyEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future postStartDefaultInstance(int contractId, String address, String name, double amount, String publicKey, String txHash, String nodeProvider, String nodeRegion,) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(
        address,
        txHash,
        name:name,
        amount:amount,
        publicKey:publicKey,
        nodeProvider:nodeProvider,
        nodeRegion:nodeRegion
    );
    print("[api] postStart , nodeDefaultEntity.toJson():${nodeDefaultEntity.toJson()}");
    NodeHttpCore.instance.post("contracts/precreate/$contractId", data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future postJoinDefaultInstance(int contractInstanceId, String address, String name, double amount, String txHash) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(
        address,
        txHash,
        name:name,
        amount:amount,
    );
    NodeHttpCore.instance.post("instances/predelegate/$contractInstanceId", data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future postWithdrawDefaultInstance(int contractInstanceId, String address, String txHash) async {
    NodeDefaultEntity nodeDefaultEntity = NodeDefaultEntity(
      address,
      txHash,
    );
    NodeHttpCore.instance.post("instances/precollect/$contractInstanceId", data: nodeDefaultEntity.toJson(), options: RequestOptions(contentType: "application/json"));
  }

  Future<String> withdrawContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, int gasLimit) async {
    var _wallet = activatedWallet.wallet;
    var createNodeWalletAddress = contractNodeItem.owner;
    var collectHex = await _wallet.sendCollectMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      gasPrice: BigInt.from(gasPrice),
      gasLimit: gasLimit,
      password: password,
    );
    print('collectHex is: $collectHex');

    await postTransactionHistory(_wallet.getEthAccount().address, contractNodeItem.id, collectHex
        , transactionHistoryAction2String(TransactionHistoryAction.WITHDRAW), double.parse(contractNodeItem.amountDelegation));

    await postWithdrawDefaultInstance(contractNodeItem.id, _wallet.getEthAccount().address, collectHex);

    return "success";
  }

  Future<bool> checkIsDelegatedContractInstance(int contractId) async {
    var isDelegated = await NodeHttpCore.instance.getEntity("/delegations/instance/$contractId/isdelegated", EntityFactory<bool>((data) {
      return data;
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true, hasAddress: true)));

    return isDelegated;
  }

  Future<bool> checkIsCreateContractInstance(int contractId) async {
    var isDelegated = await NodeHttpCore.instance.getEntity("/contracts/isUserCreatable", EntityFactory<bool>((data) {
      return data;
    }),options: RequestOptions(headers: getOptionHeader(hasLang: true, hasAddress: true)));

    return isDelegated;
  }
}
