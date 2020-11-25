
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

class BaseError{
  static Map<String, String> errorMap = {
    "already known" : S.of(Keys.rootKey.currentContext).transaction_contained_within_pool,
    "invalid sender" : S.of(Keys.rootKey.currentContext).sender_signature_error,
    "transaction underpriced" : S.of(Keys.rootKey.currentContext).gas_price_too_low,
    "replacement transaction underpriced" : S.of(Keys.rootKey.currentContext).replacement_transaction_underpriced,
    "exceeds block gas limit" : S.of(Keys.rootKey.currentContext).gas_limit_too_large,
    "negative value" : S.of(Keys.rootKey.currentContext).transaction_value_disable,
    "oversized data" : S.of(Keys.rootKey.currentContext).oversized_data,
    "map3 node does not exist" : S.of(Keys.rootKey.currentContext).map3_node_no_exist,
    "map3 node identity exists" : S.of(Keys.rootKey.currentContext).map3_node_identity_exists,
    "map3 node key exists" : S.of(Keys.rootKey.currentContext).map3_node_key_exists,
    "invalid map3 node operator" : S.of(Keys.rootKey.currentContext).is_not_map3_operator,
    "microdelegation does not exist" : S.of(Keys.rootKey.currentContext).map3_delegation_no_exist,
    "invalid map3 node status for delegation" : S.of(Keys.rootKey.currentContext).invalid_map3_status_delegation,
    "invalid map3 node status to unmicrodelegate" : S.of(Keys.rootKey.currentContext).invalid_map3_status_undelegate,
    "insufficient balance to unmicrodelegate" : S.of(Keys.rootKey.currentContext).no_balance_to_undelegate,
    "microdelegation still locked" : S.of(Keys.rootKey.currentContext).map3_delegation_still_locked,
    "not allow to terminate map3 node" : S.of(Keys.rootKey.currentContext).map3_not_to_terminate,
    "self delegation amount too small" : S.of(Keys.rootKey.currentContext).map3_creator_delegation_too_small,
    "not allow to edit terminated map3 node" : S.of(Keys.rootKey.currentContext).not_edit_terminated_map3,
    "not allow to renew map3 node" : S.of(Keys.rootKey.currentContext).not_renew_map3_node,
    "not allow to change renewal decision" : S.of(Keys.rootKey.currentContext).not_change_renewal_decision,
    "not allow to update commission by non-operator" : S.of(Keys.rootKey.currentContext).non_operator_not_update_commission,
    "map3 node not renewal any more" : S.of(Keys.rootKey.currentContext).map3_not_renewal_any_more,
    "invalid map3 node status to restake" : S.of(Keys.rootKey.currentContext).invalid_map3_status_restake,
    "map3 node already restaked" : S.of(Keys.rootKey.currentContext).map3_node_already_restaked,
    "validator address not equal to the address of the validator map3 already restaked to" : S.of(Keys.rootKey.currentContext).validator_address_not_equal_map3_restaked,

    "no stateDB was provided" : S.of(Keys.rootKey.currentContext).statedb_no_provided,
    "no chain context was provided" : S.of(Keys.rootKey.currentContext).chaincontext_no_provided,
    "no epoch was provided" : S.of(Keys.rootKey.currentContext).epoch_no_provided,
    "no block number was provided" : S.of(Keys.rootKey.currentContext).block_num_no_provided,
    "amount can not be negative" : S.of(Keys.rootKey.currentContext).amount_not_be_negative,
    "invalid signer for staking transaction" : S.of(Keys.rootKey.currentContext).invalid_signer_transaction,
    "validator identity exists" : S.of(Keys.rootKey.currentContext).validator_identity_exists,
    "slot keys can not have duplicates" : S.of(Keys.rootKey.currentContext).slot_keys_was_duplicates,
    "insufficient balance to stake" : S.of(Keys.rootKey.currentContext).no_enough_balance_stake,
    "change on commission rate can not be more than max change rate within the same epoch" : S.of(Keys.rootKey.currentContext).change_commission_rate_more_change_rate,
    "delegation amount too small" : S.of(Keys.rootKey.currentContext).delegation_amount_too_small,
    "no rewards to collect" : S.of(Keys.rootKey.currentContext).no_rewards_to_collect,
    "validator does not exist" : S.of(Keys.rootKey.currentContext).validator_not_exist,
    "redelegation does not exist" : S.of(Keys.rootKey.currentContext).redelegation_not_exist,
    "invalid validator operator" : S.of(Keys.rootKey.currentContext).invalid_validator_operator,
    "total delegation can not be bigger than max_total_delegation" : S.of(Keys.rootKey.currentContext).atlas_node_more_max_delegation,
    "insufficient balance to undelegate" : S.of(Keys.rootKey.currentContext).no_balance_undelegate,
    "self delegation too little" : S.of(Keys.rootKey.currentContext).atlas_creator_delegation_little,
  };

  static String getChainErrorReturn(String errorStr){
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
