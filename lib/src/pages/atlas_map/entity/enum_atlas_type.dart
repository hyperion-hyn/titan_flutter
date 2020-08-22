// type
/*
  0 一般转账；
  1 创建map3节点；
  2 裂变map3节点；
  3 撤销map3节点；
  4 参与map3抵押；
  5 撤销map3抵押；
  6 创建atlas节点；
  7 参与atlas节点抵押；
  8 撤销atlas节点抵押
   */

enum AtlasActionType {
  TRANSFER,
  CREATE_MAP3_NODE,
  SPLIT_MAP3_NODE,
  CANCEL_MAP3_NODE,
  JOIN_DELEGATE_MAP3,
  CANCEL_DELEGATE_MAP3,
  CREATE_ATLAS_NODE,
  JOIN_DELEGATE_ALAS,
  CANCEL_DELEGATE_ALAS
}

/*
 1创建提交中；
 2创建失败;
 3创建成功，没有撤销中；
 4创建成功，撤销节点提交中；
 5撤销节点成功
*/
enum NodeStatus {
  CREATE_ING,
  CREATE_FAIL,
  CREATE_SUCCESS_UN_CANCEL,
  CREATE_SUCCESS_CANCEL_NODE_ING,
  CREATE_SUCCESS_CANCEL_NODE_SUCCESS,
}

//节点选举情况，0候选节点，1清算节点，2出块节点
enum AtlasNodeType {
  CANDIDATE,
  SETTLE,
  BLOCK
}

//0无参与，1参与抵押，2创建者
enum NodeJoinType {
  NONE,
  JOINER,
  CREATOR
}