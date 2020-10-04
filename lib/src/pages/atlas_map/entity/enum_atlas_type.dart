// type

/*
 1 创建提交中；
 2 创建失败;
 3 募资中,没在撤销节点;
 4 募资中，撤销节点提交中；撤销节点失败回到3状态
 5 撤销节点成功；
 6 合约已启动；
 7 合约期满终止；
*/
enum Map3InfoStatus {
  CREATE_SUBMIT_ING,
  CREATE_FAIL,
  FUNDRAISING_NO_CANCEL,
  FUNDRAISING_CANCEL_SUBMIT,
  CANCEL_NODE_SUCCESS,
  CONTRACT_HAS_STARTED,
  CONTRACT_IS_END,
}

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
  9 修改atlas节点；
  10 重新激活Atlas；
  11 领取atlas奖励；
  12 领取map3奖励;
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
  CANCEL_DELEGATE_ALAS,
  EDIT_ATLAS_NODE,
  ACTIVE_ATLAS_NODE,
  RECEIVE_ATLAS_REWARD,
  RECEIVE_MAP3_REWARD,
  EDIT_MAP3_NODE,
  COLLECT_MAP3_NODE,
}

//节点选举情况，0候选节点，1清算节点，2出块节点
enum AtlasNodeType {
  CANDIDATE,
  SETTLE,
  BLOCK
}

String getAtlasNodeType(int atlasNodeType){
  AtlasNodeType nodeType = AtlasNodeType.values[atlasNodeType];
  switch(nodeType){
    case AtlasNodeType.CANDIDATE:
      return "候选节点";
    case AtlasNodeType.SETTLE:
      return "清算节点";
    case AtlasNodeType.BLOCK:
      return "出块节点";
    default:
      return "";
  }
}

//0参与抵押，1创建者
enum NodeJoinType {
  JOINER,
  CREATOR
}

/*
 1 创建提交中；
 2 创建失败;
 3 创建成功，没有撤销中；
 4 创建成功，撤销节点提交中,如果撤销失败将回到3状态；
 5 撤销节点成功/在闲置状态；
*/
enum AtlasInfoStatus {
  CREATE_ING,
  CREATE_FAIL,
  CREATE_SUCCESS_UN_CANCEL,
  CREATE_SUCCESS_CANCEL_NODE_ING,
  CANCEL_NODE_SUCCESS_IS_IDLE,
}

/*
 1 参与抵押提交中；
 2 参与抵押失败;
 3 抵押成功,没在撤销；
 4 抵押成功,撤销抵押提交中，撤销失败回到状态3；
 5 撤销抵押成功
*/
enum Map3AtlasStatus {
  JOIN_DELEGATE_ING,
  JOIN_DELEGATE_FAIL,
  DELEGATE_SUCCESS_NO_CANCEL,
  DELEGATE_SUCCESS_CANCEL_ING,
  CANCEL_DELEGATE_SUCCESS,
}

String getMap3AtlasStatusRemind(int map3atlasStatus){
  Map3AtlasStatus map3atlas = Map3AtlasStatus.values[map3atlasStatus];
  switch(map3atlas){
    case Map3AtlasStatus.JOIN_DELEGATE_ING:
      return "你已经抵押该Atlas节点，将在下一纪元生效。";
    case Map3AtlasStatus.DELEGATE_SUCCESS_CANCEL_ING:
      return "你已经撤销抵押该Atlas节点，将在下一纪元生效。";
    default:
      return "";
  }
}

/*
 1 参与抵押提交中
 2 参与抵押失败;
 3 抵押成功,没在撤销
 4 抵押成功,部分/全部撤销提交中；注：4部分撤销成功或撤销抵押失败的话回到3状态，staking改变但大于0;
 5 全部撤销抵押成功，抵押量为0。
*/
enum UserMap3Status {
  JOIN_DELEGATE_ING,
  JOIN_DELEGATE_FAIL,
  DELEGATE_SUCCESS_NO_CANCEL,
  DELEGATE_SUCCESS_CANCEL_ING,
  CANCEL_DELEGATE_SUCCESS,
}

/*
 1 一般参与者；
 2 创建者;
*/
enum UserCreator {
  NORMAL_PARTNER,
  CREATOR
}