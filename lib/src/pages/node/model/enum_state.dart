
// ContractState
ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

enum ContractState { PENDING, CANCELLED, CANCELLED_COMPLETED, ACTIVE, DUE, DUE_COMPLETED}


// UserDelegateState
UserDelegateState enumUserDelegateStateFromString(String fruit) {
  fruit = 'UserDelegateState.$fruit';
  return UserDelegateState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

enum UserDelegateState { PENDING, CANCELLED, CANCELLED_COLLECTED , ACTIVE, HALFDUE, HALFDUE_COLLECTED, DUE, DUE_COLLECTED}


// BillsOperaState
BillsOperaState enumBillsOperaStateFromString(String fruit) {
  fruit = 'BillsOperaState.$fruit';
  return BillsOperaState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

enum BillsOperaState { DELEGATE, WITHDRAW}


// TransactionHistoryState
enum TransactionHistoryState { PENDING, SUCCESS, FAIL}

TransactionHistoryState enumTransactionHistoryStateFromString(String fruit) {
  fruit = 'TransactionHistoryState.$fruit';
  return TransactionHistoryState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}


// TransactionHistoryAction
enum TransactionHistoryAction { APPROVE, CREATE_NODE, DELEGATE, WITHDRAW}
TransactionHistoryAction enumTransactionHistoryActionFromString(String fruit) {
  fruit = 'TransactionHistoryAction.$fruit';
  return TransactionHistoryAction.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

String transactionHistoryAction2String(TransactionHistoryAction action) {
  return action.toString().split(".").last ?? "";
}
