


import 'dart:convert';

import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/node_product_page_vo.dart';

class MemoryCache {
  static var NODE_SHARE_USER_KEY = "node_share_user_key";
  static var NODE_PAGE_DATA_CACHE_KEY = "node_page_data_cache_key";
  static var NODE_PRODUCT_PAGE_DATA_CACHE_KEY = "node_product_page_data_cache_key";
  static var instance = MemoryCache();

  var memoryMap = Map();

  void setMemoryMap(String key,String value){
      memoryMap.update(key,(value){
        return value;
      },ifAbsent: () => value);
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

}
