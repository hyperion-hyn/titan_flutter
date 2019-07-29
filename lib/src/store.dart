var globalStore = {};

Map<String, dynamic> getStoreOfGlobal(String storeName) {
  if (globalStore[storeName] == null) {
    globalStore[storeName] = Map<String, dynamic>();
  }
  return globalStore[storeName];
}

enum StoreKey {
  Search
}