
class BaseError{
  static Map<String, String> errorMap = {
    "already known" : "-70001",
    "invalid sender" : "-70002",
    "transaction underpriced" : "-70003",
    "replacement transaction underpriced" : "-70004",
    "exceeds block gas limit" : "-70005",
    "negative value" : "-70006",
    "oversized data" : "-70007",
    "map3 node does not exist" : "-70008",
    "map3 node identity exists" : "-70009",
    "map3 node key exists" : "-70010",
    "invalid map3 node operator" : "-70011",
    "microdelegation does not exist" : "-70012",
    "invalid map3 node status for delegation" : "-70013",
    "invalid map3 node status to unmicrodelegate" : "-70014",
    "insufficient balance to unmicrodelegate" : "-70015",
    "microdelegation still locked" : "-70016",
    "not allow to terminate map3 node" : "-70017",
    "self delegation amount too small" : "-70018",
    "not allow to edit terminated map3 node" : "-70019",
    "not allow to renew map3 node" : "-70020",
    "not allow to change renewal decision" : "-70021",
    "not allow to update commission by non-operator" : "-70022",
    "map3 node not renewal any more" : "-70023",
    "invalid map3 node status to restake" : "-70024",
    "map3 node already restaked" : "-70025",
    "validator address not equal to the address of the validator map3 already restaked to" : "-70026",

    "no stateDB was provided" : "-70027",
    "no chain context was provided" : "-70028",
    "no epoch was provided" : "-70029",
    "no block number was provided" : "-70030",
    "amount can not be negative" : "-70031",
    "invalid signer for staking transaction" : "-70032",
    "validator identity exists" : "-70033",
    "slot keys can not have duplicates" : "-70034",
    "insufficient balance to stake" : "-70035",
    "change on commission rate can not be more than max change rate within the same epoch" : "-70036",
    "delegation amount too small" : "-70037",
    "no rewards to collect" : "-70038",
    "validator does not exist" : "-70039",
    "redelegation does not exist" : "-70040",
    "invalid validator operator" : "-70041",
    "total delegation can not be bigger than max_total_delegation" : "-70042",
    "insufficient balance to undelegate" : "-70043",
    "self delegation too little" : "-70044",
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
