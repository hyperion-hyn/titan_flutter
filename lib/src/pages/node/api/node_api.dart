
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class NodeApi {

 
  Future<List<ContractNodeItem>> getMyCreateNodeContract() async {
    return await HttpCore.instance
        .getEntity("delegations/my-create",
        EntityFactory<List<ContractNodeItem>>((list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {"Address": "jifijfkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<ContractNodeItem>> getMyJoinNodeContract() async {
    return await HttpCore.instance
        .getEntity("delegations/my-join",
      EntityFactory<List<ContractNodeItem>>((list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<ContractDetailItem> getContractDetail(int contractNodeItemId) async {
    return await HttpCore.instance
        .getEntity("delegations/instance/$contractNodeItemId",
        EntityFactory<ContractDetailItem>((data) =>
            ContractDetailItem.fromJson(data)),
        options: RequestOptions(
            headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<ContractDelegatorItem>> getContractDelegator(int contractNodeItemId, {int page = 0}) async {
    return await HttpCore.instance
        .getEntity("delegations/instance/$contractNodeItemId/delegators",
        EntityFactory<List<ContractDelegatorItem>>((list) => (list as List).map((item) => ContractDelegatorItem.fromJson(item)).toList()),
        params: {"page": page},
        options: RequestOptions(headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<NodeItem>> getContractList(int page) async {
    var contractsList = await HttpCore.instance
        .getEntity("contracts/list?page=$page", EntityFactory<List<NodeItem>>((data){
          return (data as List).map((dataItem)=>NodeItem.fromJson(dataItem)).toList();
        }));

    return contractsList;
  }

  Future<ContractNodeItem> getContractItem(String contractId) async {
    var nodeItem = await HttpCore.instance
        .getEntity("contracts/detail/$contractId", EntityFactory<NodeItem>((data){
      return NodeItem.fromJson(data);
    }));

    return ContractNodeItem.onlyNodeItem(nodeItem);
  }

  Future<ContractNodeItem> getContractInstanceItem(String contractId) async {
    var contractsItem = await HttpCore.instance
        .getEntity("instances/detail/$contractId", EntityFactory<ContractNodeItem>((data){
      return ContractNodeItem.fromJson(data);
    }));

    return contractsItem;
  }

  Future<String> startContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password, int gasPrice,
      String contractId, StartJoinInstance startJoinInstance) async {
    var wallet = activatedWallet.wallet;

//    var maxStakingAmount = 1000000; //一百万
    var maxStakingAmount = contractNodeItem.contract.minTotalDelegation; //一百万
    var myStaking = contractNodeItem.contract.ownerMinDelegationRate * maxStakingAmount; //最小抵押量
    var hynErc20ContractAddress = wallet.getEthAccount().contractAssetTokens[0].contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;

    //approve
    var approveSignedHex = await wallet.signApproveErc20Token(
    contractAddress: hynErc20ContractAddress,
    approveToAddress: approveToAddress,
    amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
    password: password,
    gasPrice: BigInt.from(gasPrice),
    gasLimit: 50000);

    var nodeKey = await HttpCore.instance
        .getEntity("contracts/create/$contractId", EntityFactory<Map<String, dynamic>>((data){
      return data;
    }));

    int durationType = contractNodeItem.contract.duration; //0: 1月， 1: 3月， 2: 6月
    var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.

    //create
    var createSignedHex = await wallet.signCreateMap3Node(
      stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      type: durationType,
      firstHalfPubKey: nodeKey["firstHalfPubKey"],
      secondHalfPubKey: nodeKey["secondHalfPubKey"],
      gasPrice: BigInt.from(gasPrice),
      gasLimit: gasLimit,
      password: password,
    );

    startJoinInstance.approveData = approveSignedHex;
    startJoinInstance.createData = createSignedHex;

    String postData = json.encode(startJoinInstance.toJson());
    var data = await HttpCore.instance
        .post("contracts/create/$contractId", data: postData,
        options: RequestOptions(contentType: "application/json"));
    return data['msg'];
  }

  Future<String> joinContractInstance(ContractNodeItem contractNodeItem, WalletVo activatedWallet, String password, int gasPrice,
      createNodeWalletAddress, String contractId,StartJoinInstance startJoinInstance) async {
    var wallet = activatedWallet.wallet;

    var maxStakingAmount = contractNodeItem.contract.minTotalDelegation; //一百万
    var myStaking = contractNodeItem.contract.ownerMinDelegationRate * maxStakingAmount; //最小抵押量
    var hynErc20ContractAddress = wallet.getEthAccount().contractAssetTokens[0].contractAddress;
    var approveToAddress = WalletConfig.map3ContractAddress;

    //approve
    var approveSignedHex = await wallet.signApproveErc20Token(
        contractAddress: hynErc20ContractAddress,
        approveToAddress: approveToAddress,
        amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
        password: password,
        gasPrice: BigInt.from(gasPrice),
        gasLimit: 50000);

//    var createNodeWalletAddress = wallet0.getEthAccount().address; //创建节点合约的钱包地址
    var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.

    var joinSignedHex = await wallet.signDelegateMap3Node(
      createNodeWalletAddress: createNodeWalletAddress,
      stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
      gasPrice: BigInt.from(gasPrice),
      gasLimit: gasLimit,
      password: password,
    );

    String postData = json.encode(startJoinInstance.toJson());
    var data = await HttpCore.instance
        .post("instances/delegate/$contractId", data: postData,
        options: RequestOptions(contentType: "application/json"));
    return data['msg'];
  }

  Future<NodePageEntityVo> getNodePageEntityVo() async {
    var nodeHeadEntity = await HttpCore.instance
        .getEntity("nodes/intro", EntityFactory<NodeHeadEntity>((data){
      return NodeHeadEntity.fromJson(data);
    }));

    var pendingList = await getContractPendingList(0);

    return NodePageEntityVo(nodeHeadEntity, pendingList);
  }

  Future<List<ContractNodeItem>> getContractPendingList(int page) async {
    var contractsList = await HttpCore.instance
        .getEntity("instances/pending?page=$page", EntityFactory<List<ContractNodeItem>>((data){
      return (data as List).map((dataItem)=>ContractNodeItem.fromJson(dataItem)).toList();
    }));

    return contractsList;
  }


}