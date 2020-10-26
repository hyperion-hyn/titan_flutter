// ContractState
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';

ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

enum ContractState {
  PRE_CREATE,
  PENDING,
  CANCELLED,
  CANCELLED_COMPLETED,
  ACTIVE,
  DUE,
  DUE_COMPLETED,
  FAIL
}

//0映射中;1 创建提交中；2创建失败; 3募资中,没在撤销节点;4募资中，撤销节点提交中，如果撤销失败将回到3状态；5撤销节点成功；6合约已启动；7合约期满终止；
// ContractState
Map3InfoStatus enumMap3InfoStatusFromString(String fruit) {
  fruit = 'Map3InfoStatus.$fruit';
  return Map3InfoStatus.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

/*
enum Map3InfoStatus {
  Map,
  PRE_CREATE,
  FAIL,
  PENDING,
  CANCELLED,
  CANCELLED_COMPLETED,
  ACTIVE,
  DUE,
}*/

// UserDelegateState
UserDelegateState enumUserDelegateStateFromString(String fruit) {
  fruit = 'UserDelegateState.$fruit';
  return UserDelegateState.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

enum UserDelegateState {
  PRE_CREATE,
  PENDING,
  CANCELLED,
  PRE_CANCELLED_COLLECTED,
  CANCELLED_COLLECTED,
  ACTIVE,
  HALFDUE,
  PRE_HALFDUE_COLLECTED,
  HALFDUE_COLLECTED,
  DUE,
  PRE_DUE_COLLECTED,
  DUE_COLLECTED,
  FAIL
}

// BillsOperaState
BillsOperaState enumBillsOperaStateFromString(String fruit) {
  fruit = 'BillsOperaState.$fruit';
  return BillsOperaState.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

enum BillsOperaState { DELEGATE, WITHDRAW }

// BillsRecordState
BillsRecordState enumBillsRecordStateFromString(String fruit) {
  fruit = 'BillsRecordState.$fruit';
  return BillsRecordState.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

enum BillsRecordState { PRE_CREATE, CONFIRMED, FAIL }

// TransactionHistoryState
enum TransactionHistoryState { PENDING, SUCCESS, FAIL }

TransactionHistoryState enumTransactionHistoryStateFromString(String fruit) {
  fruit = 'TransactionHistoryState.$fruit';
  return TransactionHistoryState.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

// TransactionHistoryAction
enum TransactionHistoryAction { APPROVE, CREATE_NODE, DELEGATE, WITHDRAW }

TransactionHistoryAction enumTransactionHistoryActionFromString(String fruit) {
  fruit = 'TransactionHistoryAction.$fruit';
  return TransactionHistoryAction.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

String transactionHistoryAction2String(TransactionHistoryAction action) {
  return action.toString().split(".").last ?? "";
}

enum AppSource { DEFAULT, TITAN, STARRICH }

enum Map3NodeActionEvent {

  // Map3
  MAP3_CREATE,
  MAP3_DELEGATE,
  MAP3_COLLECT,
  MAP3_CANCEL,
  MAP3_CANCEL_CONFIRMED,
  MAP3_ADD,
  MAP3_EDIT,
  MAP3_PRE_EDIT,
  MAP3_TERMINAL,
  RECEIVE_AWARD,
  EDIT_ATLAS,
  ACTIVE_NODE,
  STAKE_ATLAS,
 

  //Atlas
  ATLAS_CREATE,
  ATLAS_EDIT,
  ATLAS_RECEIVE_AWARD,
  ATLAS_ACTIVE_NODE,
  ATLAS_STAKE,
  ATLAS_CANCEL_STAKE,

  //Other

  EXCHANGE_HYN,
}

Map3NodeActionEvent enumActionEventFromString(String fruit) {
  return Map3NodeActionEvent.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

enum AtlasNodeActionEvent { CREATE }

AtlasNodeActionEvent atlasActionEventFromString(String fruit) {
  return AtlasNodeActionEvent.values
      .firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

