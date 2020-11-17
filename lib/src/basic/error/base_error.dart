
class BaseError{
  static Map<String, String> errorMap = {
    "already known" : "交易已经包含在队列中了",
    "invalid sender" : "发送者签名异常",
    "transaction underpriced" : "交易价格过低",
    "replacement transaction underpriced" : "覆盖交易价格过低",
    "exceeds block gas limit" : "燃料值过大",
    "negative value" : "转账价值为负数",
    "oversized data" : "负载数据过大",
    "map3 node does not exist" : "Map3节点不存在",
    "map3 node identity exists" : "Map3节点号已存在",
    "map3 node key exists" : "Map3节点BLS KEY已存在",
    "invalid map3 node operator" : "非Map3创建人",
    "microdelegation does not exist" : "Map3抵押不存在",
    "invalid map3 node status for delegation" : "Map3节点当前状态不允许抵押",
    "invalid map3 node status to unmicrodelegate" : "Map3节点当前状态不允许取消抵押",
    "insufficient balance to unmicrodelegate" : "申请取消抵押的金额大于余额",
    "microdelegation still locked" : "Map3抵押仍在锁定周期",
    "not allow to terminate map3 node" : "不允许中止Map3节点",
    "self delegation amount too small" : "Map3创建者抵押金额太低",
    "not allow to edit terminated map3 node" : "不允许编辑已中止的Map3节点",
    "not allow to renew map3 node" : "不允许续期Map3节点",
    "not allow to change renewal decision" : "不允许更改续期决定",
    "not allow to update commission by non-operator" : "非创建者不允许更新费率",
    "map3 node not renewal any more" : "该节点不再续期",
    "invalid map3 node status to restake" : "Map3状态不允许复抵押",
    "map3 node already restaked" : "Map3节点已经复抵押",
    "validator address not equal to the address of the validator map3 already restaked to" : "Atlas节点与已复抵押节点地址不一致",

    "no stateDB was provided" : "StateDB为空",
    "no chain context was provided" : "ChainContext为空",
    "no epoch was provided" : "纪元为空",
    "no block number was provided" : "区块高度为空",
    "amount can not be negative" : "金额不允许为负数",
    "invalid signer for staking transaction" : "非法的交易签名",
    "validator identity exists" : "Atlas节点号已存在",
    "slot keys can not have duplicates" : "Atlas节点BLS KEY重复",
    "insufficient balance to stake" : "余额不足以抵押",
    "change on commission rate can not be more than max change rate within the same epoch" : "更新的费率大于允许最大更改量",
    "delegation amount too small" : "抵押金额太低",
    "no rewards to collect" : "无可提取收益",
    "validator does not exist" : "Atlas节点不存在",
    "redelegation does not exist" : "复抵押不存在",
    "invalid validator operator" : "非Atlas节点创建者",
    "total delegation can not be bigger than max_total_delegation" : "Atlas节点总抵押量大于允许最大抵押量",
    "insufficient balance to undelegate" : "申请取消复抵押的金额大于余额",
    "self delegation too little" : "Atlas创建者抵押金额太低",
  };

  static String getErrorCode(String errorStr){
    if(errorStr == null || errorStr.isEmpty){
      return errorStr;
    }
    String resultStr = errorStr;
    errorMap.keys.forEach((element) {
      if(errorStr.contains(element)){
        resultStr = errorMap[element];
      }
    });
    return resultStr;
  }
}
