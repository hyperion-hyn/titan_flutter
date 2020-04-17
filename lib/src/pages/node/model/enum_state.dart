
// ContractState
ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

enum ContractState { PRE_CREATE, PENDING, CANCELLED, CANCELLED_COMPLETED, ACTIVE, DUE, DUE_COMPLETED, FAIL}


// UserDelegateState
UserDelegateState enumUserDelegateStateFromString(String fruit) {
  fruit = 'UserDelegateState.$fruit';
  return UserDelegateState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}

enum UserDelegateState { PRE_CREATE, PENDING, CANCELLED, PRE_CANCELLED_COLLECTED, CANCELLED_COLLECTED , ACTIVE, HALFDUE, PRE_HALFDUE_COLLECTED, HALFDUE_COLLECTED, DUE, PRE_DUE_COLLECTED, DUE_COLLECTED,FAIL}


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
