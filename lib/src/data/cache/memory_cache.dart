

var NODE_SHARE_USER_KEY = "node_share_user_key";

var memoryMap = Map();

void setMemoryMap(String key,String value){
  memoryMap.putIfAbsent(key,() => value);
}

String getMemoryMap(String key){
  return memoryMap[key];
}