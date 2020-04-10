import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class NodeApi {

  Future<List<ContractNodeItem>> getMyCreateNodeContract({int page = 0, String address = "jifijfkeo904o3jfi0joitqjjfli"}) async {
    return await HttpCore.instance.getEntity(
        "delegations/my-create",
        EntityFactory<List<ContractNodeItem>>(
            (list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: {"Address": address}));
  }

  Future<List<ContractNodeItem>> getMyJoinNodeContract({int page = 0, String address = "jifijfkeo904o3jfi0joitqjjfli"}) async {
    return await HttpCore.instance.getEntity(
        "delegations/my-join",
        EntityFactory<List<ContractNodeItem>>(
            (list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: {"Address": address}));
  }

  Future<ContractDetailItem> getContractDetail(int contractNodeItemId, {String address = "jifijfkeo904o3jfi0joitqjjfli"}) async {
    return await HttpCore.instance.getEntity("delegations/instance/$contractNodeItemId",
        EntityFactory<ContractDetailItem>((data) => ContractDetailItem.fromJson(data)),
        options: RequestOptions(headers: {"Address": address}));
  }

  Future<List<ContractDelegatorItem>> getContractDelegator(int contractNodeItemId, {int page = 0, String address = "jifijfkeo904o3jfi0joitqjjfli"}) async {
    return await HttpCore.instance.getEntity(
        "delegations/instance/$contractNodeItemId/delegators",
        EntityFactory<List<ContractDelegatorItem>>(
            (list) => (list as List).map((item) => ContractDelegatorItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: {"Address": address}));
  }

  Future<List<NodeItem>> getContractList(int page) async {
    var contractsList =
        await HttpCore.instance.getEntity("contracts/list?page=$page", EntityFactory<List<NodeItem>>((data) {
      return (data as List).map((dataItem) => NodeItem.fromJson(dataItem)).toList();
    }));

    return contractsList;
  }

  Future<List<NodeProviderEntity>> getNodeProviderList() async {
    var nodeProviderList =
    await HttpCore.instance.getEntity("nodes/providers", EntityFactory<List<NodeProviderEntity>>((data) {
      return (data as List).map((dataItem) => NodeProviderEntity.fromJson(dataItem)).toList();
    }));

    return nodeProviderList;
  }

  Future<ContractNodeItem> getContractItem(String contractId) async {
    var nodeItem = await HttpCore.instance.getEntity("contracts/detail/$contractId", EntityFactory<NodeItem>((data) {
      return NodeItem.fromJson(data);
    }));

    return ContractNodeItem.onlyNodeItem(nodeItem);
  }

  Future<ContractNodeItem> getContractInstanceItem(String contractId) async {
    var contractsItem =
        await HttpCore.instance.getEntity("instances/detail/$contractId", EntityFactory<ContractNodeItem>((data) {
      return ContractNodeItem.fromJson(data);
    }));

    return contractsItem;
  }

  Future<String> startContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, String contractId, StartJoinInstance startJoinInstance,double amount) async {
    var wallet = activatedWallet.wallet;
//    var maxStakingAmount = 1000000; //一百万
    var myStaking = amount;
    var ethAccount = wallet.getEthAccount();
    var hynAssetToken = wallet.getHynToken();
    var hynErc20ContractAddress = hynAssetToken?.contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;

    var nodeKey = await HttpCore.instance.getEntity("nodekey/generate", EntityFactory<Map<String, dynamic>>((data) {
      return data;
    }));
    int durationType = contractNodeItem.contract.durationType; //0: 1M， 1: 3M， 2: 6M

    final client = WalletUtil.getWeb3Client();
    var count =
        await client.getTransactionCount(EthereumAddress.fromHex(ethAccount.address), atBlock: BlockNum.pending());

    //approve
    print('approve result: $count');
    var approveTx = await wallet.sendApproveErc20Token(
        contractAddress: hynErc20ContractAddress,
        approveToAddress: approveToAddress,
        amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
        password: password,
        gasPrice: BigInt.from(gasPrice),
        gasLimit: EthereumConst.ERC20_APPROVE_GAS_LIMIT,
        nonce: count);
    print('approve result: $approveTx');

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

//    startJoinInstance.txHash = createMap3Hex;
//    startJoinInstance.publicKey = nodeKey["publicKey"];
    String postData = json.encode(startJoinInstance.toJson());
    print("startContractInstance = $postData");
    var data = await HttpCore.instance
        .post("node-provider", data: postData, options: RequestOptions(contentType: "application/json"));
    return data['msg'];
    return "success";
  }

  Future<String> joinContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password,
      int gasPrice, createNodeWalletAddress, String contractId, double amount) async {
    var wallet = activatedWallet.wallet;

    var myStaking = amount;
    var ethAccount = wallet.getEthAccount();
    var hynErc20ContractAddress = wallet.getEthAccount().contractAssetTokens[0].contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;

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

    var joinHex = await wallet.sendDelegateMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      gasPrice: BigInt.from(gasPrice),
      gasLimit: EthereumConst.DELEGATE_MAP3_NODE_GAS_LIMIT,
      password: password,
      nonce: count + 1,
    );
    print('joinHex is: $joinHex');

//    startJoinInstance.txHash = joinHex;
//    String postData = json.encode(startJoinInstance.toJson());
//    print("joinContractInstance = $postData");
//    var data = await HttpCore.instance.post("instances/delegate/$contractId",
//        data: postData, options: RequestOptions(contentType: "application/json"));
//    return data['msg'];
    return "success";
  }

  Future<NodePageEntityVo> getNodePageEntityVo() async {
    var nodeHeadEntity = await HttpCore.instance.getEntity("nodes/intro", EntityFactory<NodeHeadEntity>((data) {
      return NodeHeadEntity.fromJson(data);
    }));

    var pendingList = await getContractPendingList(0);

    return NodePageEntityVo(nodeHeadEntity, pendingList);
  }

  Future<List<ContractNodeItem>> getContractPendingList(int page) async {
    var contractsList =
        await HttpCore.instance.getEntity("instances/pending?page=$page", EntityFactory<List<ContractNodeItem>>((data) {
      return (data as List).map((dataItem) => ContractNodeItem.fromJson(dataItem)).toList();
    }));

    return contractsList;
  }
}
