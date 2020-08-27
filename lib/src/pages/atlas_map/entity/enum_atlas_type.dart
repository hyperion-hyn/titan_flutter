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
 1 创建提交中；
 2 创建失败;
 3 创建成功，没有撤销中；
 4 创建成功，撤销节点提交中；
 5 撤销节点成功；撤销节点失败回到3状态
*/
enum AtlasNodeStatus {
  CREATE_ING,
  CREATE_FAIL,
  CREATE_SUCCESS_UN_CANCEL,
  CREATE_SUCCESS_CANCEL_NODE_ING,
  CREATE_SUCCESS_CANCEL_NODE_SUCCESS,
}

/*
 1 创建提交中；
 2 创建失败;
 3 募资中,没在撤销节点;
*/
enum Map3NodeInAtlasStatus {
  JOIN_DELEGATE_ING,
  JOIN_DELEGATE_FAIL,
  DELEGATE_SUCCESS_NO_CANCEL,
}

/*
 1 创建提交中；
 2 创建失败;
 3 募资中,没在撤销节点;
 4 募资中，撤销节点提交中；撤销节点失败回到3状态
 5 撤销节点成功；
 6 合约已启动；
 7 合约期满终止；
*/
enum Map3NodeStatus {
  CREATE_SUBMIT_ING,
  CREATE_FAIL,
  FUNDRAISING_NO_CANCEL,
  FUNDRAISING_CANCEL_SUBMIT,
  CANCEL_NODE_SUCCESS,
  CONTRACT_HAS_STARTED,
  CONTRACT_IS_END,
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