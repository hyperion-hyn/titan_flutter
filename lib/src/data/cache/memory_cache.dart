


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
    return instance.getMemoryMap(MemoryCache.NODE_SHARE_USER_KEY);
  }

}
