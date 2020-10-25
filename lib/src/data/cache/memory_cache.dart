


import 'dart:convert';

import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/node_product_page_vo.dart';

class MemoryCache {
  static var NODE_SHARE_USER_KEY = "node_share_user_key";
  static var NODE_PAGE_DATA_CACHE_KEY = "node_page_data_cache_key";
  static var MAP3_PAGE_DATA_CACHE_KEY = "map3_page_data_cache_key";
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

  static Map3PageEntityVo get map3PageData {
    String map3PageDataStr = instance.getMemoryMap(MAP3_PAGE_DATA_CACHE_KEY);
    Map3PageEntityVo map3PageEntityVo = Map3PageEntityVo(null,List());
    if(map3PageDataStr.length > 0){
      map3PageEntityVo = Map3PageEntityVo.fromJson(json.decode(map3PageDataStr));
    }
    return map3PageEntityVo;
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

  static set nodeProductPageData(NodeProductPageVo nodeProductPageVo) {
    instance.setMemoryMap(NODE_PRODUCT_PAGE_DATA_CACHE_KEY, json.encode(nodeProductPageVo.toJson()));
  }

  static setContractErrorStr(){
    var map = Map();
    var rootContext = Keys.rootKey.currentContext;
    map["nonce too low"] = S.of(Keys.rootKey.currentContext).nonce_too_low_hint;
    map["nonce too high"] = S.of(Keys.rootKey.currentContext).nonce_too_high_hint;
    map["gas limit reached"] = S.of(Keys.rootKey.currentContext).gas_limit_reached_hint;
    map["insufficient funds for transfer"] = S.of(Keys.rootKey.currentContext).insufficient_funds_for_transfer_hint;
    map["insufficient funds for gas * price + value"] = S.of(Keys.rootKey.currentContext).insufficient_funds_for_gas_price_value_hint;
    map["intrinsic gas too low"] = S.of(Keys.rootKey.currentContext).intrinsic_gas_too_low_hint;
    map["Already imported"] = S.of(Keys.rootKey.currentContext).already_imported_hint;
    map["No longer valid"] = S.of(Keys.rootKey.currentContext).no_longer_valid_hint;
    map["Transaction limit reached"] = S.of(Keys.rootKey.currentContext).transaction_limit_reached_hint;
    map["Insufficient gas price."] = S.of(Keys.rootKey.currentContext).insufficient_gas_price_hint;
    map["Gas price too low to replace"] = S.of(Keys.rootKey.currentContext).gas_price_too_low_to_replace_hint;
    map["Insufficient gas."] = S.of(Keys.rootKey.currentContext).insufficient_gas_hint;
    map["Insufficient balance for transaction. "] = S.of(Keys.rootKey.currentContext).insufficient_balance_for_transaction_hint;
    map["Gas limit exceeded."] = S.of(Keys.rootKey.currentContext).gas_limit_exceeded_hint;
    map["insufficient balance to stake"] = S.of(Keys.rootKey.currentContext).insufficient_balance_to_stake_hint;
    map["self delegation insufficient"] = S.of(Keys.rootKey.currentContext).self_delegation_insufficient_hint;
    map["delegation insufficient"] = S.of(Keys.rootKey.currentContext).delegation_insufficient_hint;
    map["not equal to remaining delegation"] = S.of(Keys.rootKey.currentContext).not_equal_to_remaining_delegation_hint;
    map["node already exist"] = S.of(Keys.rootKey.currentContext).node_already_exist_hint;
    map["node not exist"] = S.of(Keys.rootKey.currentContext).node_not_exist_hint;
    map["not allow to delegate in unpending state"] = S.of(Keys.rootKey.currentContext).not_allow_to_delegate_in_unpending_state_hint;
    map["not allow to collect in pending state"] = S.of(Keys.rootKey.currentContext).not_allow_to_collect_in_pending_state_hint;
    map["delegator not exist"] = S.of(Keys.rootKey.currentContext).delegator_not_exist_hint;
    map["not time to collect"] = S.of(Keys.rootKey.currentContext).not_time_to_collect_hint;
    map["already collected"] = S.of(Keys.rootKey.currentContext).already_collected_hint;
    map["not half time to collect"] = S.of(Keys.rootKey.currentContext).not_half_time_to_collect_hint;
    map["provision insufficient"] = S.of(Keys.rootKey.currentContext).provision_insufficient_hint;
    map["map3 node identity exists"] = S.of(Keys.rootKey.currentContext).duplicate_identity_hint;
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
    if(errorStr.indexOf("map3 node identity exists") == 0){
      return errorMap["map3 node identity exists"];
    }
    if(errorMap.containsKey(errorStr)){
      return errorMap[errorStr];
    }
    return errorStr;
  }
}
