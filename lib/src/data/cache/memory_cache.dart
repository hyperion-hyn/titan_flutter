


import 'dart:convert';

import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/node_product_page_vo.dart';

class MemoryCache {
  static var NODE_SHARE_USER_KEY = "node_share_user_key";
  static var NODE_PAGE_DATA_CACHE_KEY = "node_page_data_cache_key";
  static var NODE_PRODUCT_PAGE_DATA_CACHE_KEY = "node_product_page_data_cache_key";
  static var CONTRACT_ERROR_TRANSLATION = "contract_error_translation";
  static var instance = MemoryCache();

  var memoryMap = Map();

  void setMemoryMap(String key,String value){
//      memoryMap.update(key,(value){
//        return value;
//      },ifAbsent: () => value);
    memoryMap[key] = value;
  }

  String getMemoryMap(String key){
    return memoryMap[key]??"";
  }

  static get shareKey {
    return instance.getMemoryMap(NODE_SHARE_USER_KEY);
  }

  static set shareKey(String value) => instance.setMemoryMap(NODE_SHARE_USER_KEY, value);

  static NodePageEntityVo get nodePageData {
    String nodePageDataStr = instance.getMemoryMap(NODE_PAGE_DATA_CACHE_KEY);
    NodePageEntityVo nodePageEntityVo = NodePageEntityVo(null,List());
    if(nodePageDataStr.length > 0){
      nodePageEntityVo = NodePageEntityVo.fromJson(json.decode(nodePageDataStr));
    }
    return nodePageEntityVo;
  }

  static get hasNodePageData {
    String nodePageDataStr = instance.getMemoryMap(NODE_PAGE_DATA_CACHE_KEY);
    if(nodePageDataStr.length > 0){
      return true;
    }
    return false;
  }

  static set nodePageData(NodePageEntityVo nodePageEntityVo) {
    instance.setMemoryMap(NODE_PAGE_DATA_CACHE_KEY, json.encode(nodePageEntityVo.toJson()));
  }

  static NodeProductPageVo get nodeProductPageData {
    String nodeProductPageDataStr = instance.getMemoryMap(NODE_PRODUCT_PAGE_DATA_CACHE_KEY);
    List<NodeItem> nodeItemList = List();
    if(nodeProductPageDataStr.length > 0){
      nodeItemList = NodeProductPageVo.fromJson(json.decode(nodeProductPageDataStr)).nodeItemList;
    }
    return NodeProductPageVo(nodeItemList);
  }

  static get hasNodeProductPageData {
    String nodePageDataStr = instance.getMemoryMap(NODE_PRODUCT_PAGE_DATA_CACHE_KEY);
    if(nodePageDataStr.length > 0){
      return true;
    }
    return false;
  }

  static set nodeProductPageData(List<NodeItem> nodeItemList) {
    NodeProductPageVo nodeProductPageVo = NodeProductPageVo(nodeItemList);
    instance.setMemoryMap(NODE_PRODUCT_PAGE_DATA_CACHE_KEY, json.encode(nodeProductPageVo.toJson()));
  }

  static setContractErrorStr(){
    var map = Map();
    var rootContext = Keys.rootKey.currentContext;
    map["nonce too low"] = "nonce值太低";
    map["nonce too high"] = "nonce值太高";
    map["gas limit reached"] = "gas达到限制";
    map["insufficient funds for transfer"] = "转账资金不足";
    map["insufficient funds for gas * price + value"] = "gas资金不足";
    map["intrinsic gas too low"] = "固有gas太低";
    map["Already imported"] = "已导入";
    map["No longer valid"] = "不再有效";
    map["Transaction limit reached"] = "Transaction limit reached";
    map["Insufficient gas price."] = "Insufficient gas price.";
    map["Gas price too low to replace"] = "Gas price too low to replace ";
    map["Insufficient gas."] = "Insufficient gas.";
    map["Insufficient balance for transaction. "] = "Insufficient balance for transaction. ";
    map["Gas limit exceeded."] = "Gas limit exceeded.";
    map["insufficient balance to stake"] = "insufficient balance to stake";
    map["self delegation insufficient"] = "self delegation insufficient";
    map["delegation insufficient"] = "delegation insufficient";
    map["not equal to remaining delegation"] = "not equal to remaining delegation";
    map["node already exist"] = "node already exist";
    map["node not exist"] = "node not exist";
    map["not allow to delegate in unpending state"] = "not allow to delegate in unpending state";
    map["not allow to collect in pending state"] = "not allow to collect in pending state";
    map["delegator not exist"] = "delegator not exist";
    map["not time to collect"] = "not time to collect";
    map["already collected"] = "already collected";
    map["not half time to collect"] = "not half time to collect";
    map["provision insufficient"] = "provision insufficient";
    instance.setMemoryMap(CONTRACT_ERROR_TRANSLATION, json.encode(map));
  }

  static String contractErrorStr(String errorStr){
    if(instance.getMemoryMap(CONTRACT_ERROR_TRANSLATION) == ""){
      return errorStr;
    }
    Map errorMap = json.decode(instance.getMemoryMap(CONTRACT_ERROR_TRANSLATION));
    if(errorStr.indexOf("Insufficient gas price.") == 0){
      return errorMap["Insufficient gas price."];
    }
    if(errorStr.indexOf("Gas price too low to replace") == 0){
      return errorMap["Gas price too low to replace"];
    }
    if(errorStr.indexOf("Insufficient gas.") == 0){
      return errorMap["Insufficient gas."];
    }
    if(errorStr.indexOf("Insufficient balance for transaction.") == 0){
      return errorMap["Insufficient balance for transaction."];
    }
    if(errorStr.indexOf("Gas limit exceeded.") == 0){
      return errorMap["Gas limit exceeded."];
    }
    if(errorMap.containsKey(errorStr)){
      return errorMap[errorStr];
    }
    return errorStr;
  }
}
