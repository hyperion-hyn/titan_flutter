import 'package:titan/src/pages/market/model/exchange_account.dart';

class ExchangeModel {
  bool isShowBalances = true;

  ExchangeAccount activeAccount;

  bool hasActiveAccount() {
    return activeAccount != null;
  }

  bool isActiveAccountAndHasAssets() {
    return activeAccount != null && activeAccount.assetList != null;
  }
}
