


class MemoryCache {
  static var NODE_SHARE_USER_KEY = "node_share_user_key";
  static var instance = MemoryCache();

  var memoryMap = Map();

  void setMemoryMap(String key,String value){
    memoryMap.putIfAbsent(key,() => value);
  }

  String getMemoryMap(String key){
    return memoryMap[key]??"";
  }

  static get shareKey {
    return instance.getMemoryMap(NODE_SHARE_USER_KEY);
  }

  static set shareKey(String value) => instance.setMemoryMap(NODE_SHARE_USER_KEY, value);

}
