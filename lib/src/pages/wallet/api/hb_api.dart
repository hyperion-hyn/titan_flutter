import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/eth_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/hb_erc20_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/ht_transfer_history.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as web3;

class HbApi {
  static String getTxDetailUrl(String txHash) {
    return '${HecoExplore.hecoScanWeb}/tx/$txHash';
  }

  static String getAddressDetailUrl(String address) {
    return '${HecoExplore.hecoScanWeb}/address/$address';
  }

  Future<List<HtTransferHistory>> queryHtHistory(String address, int page) async {
    Map result =
        await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/coin-tx-list", params: {
      "address": address,
      "startBlock": "0",
      "endBlock": "99999999",
      "page": page,
      "offset": "10",
      "sort": "desc",
    });

    if (result["code"] == 0) {
      List resultList = result["data"] as List;
      return resultList.map((json) => HtTransferHistory.fromJson(json)).toList();
    } else {
      throw new Exception();
    }
  }

  Future<List<HbErc20TransferHistory>> queryHtErc20History(
      String contractAddress, String address, int page) async {
    Map result =
        await HttpCore.instance.get("${HecoExplore.hecoScanApi}/v1/account/token-tx-list", params: {
      "contractAddress": contractAddress,
      "address": address,
      "startBlock": "0",
      "endBlock": "99999999",
      "page": page,
      "offset": "10",
      "sort": "desc",
    });
    if (result["code"] == 0) {
      List resultList = result["data"] as List;
      return resultList.map((json) => HbErc20TransferHistory.fromJson(json)).toList();
    } else {
      throw new Exception();
    }
  }

  static bool isGasFeeEnough(BigInt gasPrice, int gasLimit, {BigInt transferAmount}) {
    var ht = WalletInheritedModel.of(Keys.rootKey.currentContext).getCoinVoBySymbolAndCoinType(
      DefaultTokenDefine.HT.symbol,
      CoinType.HB_HT,
    );
    var gasFees = gasPrice * BigInt.from(gasLimit);
    if (transferAmount == null) {
      transferAmount = BigInt.from(0);
    }
    if ((ht.balance - transferAmount) < gasFees) {
      Fluttertoast.showToast(
        msg: S.of(Keys.rootKey.currentContext).insufficient_gas_fee,
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
    return true;
  }

  Future<dynamic> postBridgeBurnToken({
    String contractAddress,
    BigInt burnAmount,
    String password = '',
    WalletViewVo activeWallet,
  }) async {
    var ownerAddress = activeWallet?.wallet?.getEthAccount()?.address ?? '';
    final client = WalletUtil.getWeb3Client(CoinType.HB_HT);
    var nonce = await client.getTransactionCount(EthereumAddress.fromHex(ownerAddress));
    var approveHex = await postApprove(
      contractAddress: contractAddress,
      password: password,
      activeWallet: activeWallet,
      amount: burnAmount,
      nonce: nonce,
    );
    if (approveHex?.isEmpty ?? true) {
      throw HttpResponseCodeNotSuccess(
        -30011,
        'Insufficient HT to pay for gas fee',
      );
    }

    print('--- approveHex $approveHex');

    ///update nonce
    nonce = nonce + 1;

    var rawTxHash = await activeWallet.wallet.signBridgeBurnToken(
      contractAddress,
      ownerAddress,
      password,
      amount: burnAmount,
      nonce: nonce,
    );

    if (rawTxHash == null) {
      throw HttpResponseCodeNotSuccess(
        -30012,
        'Insufficient Token balance',
      );
    }

    var responseMap = await WalletUtil.postToEthereumNetwork(
      CoinType.HB_HT,
      method: 'eth_sendRawTransaction',
      params: [rawTxHash],
    );

    print('$responseMap');
  }

  Future<String> postApprove({
    String contractAddress,
    String password = '',
    BigInt amount,
    WalletViewVo activeWallet,
    int nonce,
  }) async {
    var wallet = activeWallet?.wallet;
    var gasLimit = SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
        .systemConfigEntity
        .erc20ApproveGasLimit;

    var approveHex = await wallet.sendApproveErc20Token(
      contractAddress: contractAddress,
      approveToAddress: HecoConfig.burnTokenContractAddress,
      amount: amount,
      password: password,
      gasPrice: HecoGasPrice.getRecommend().fastBigInt,
      gasLimit: gasLimit,
      nonce: nonce,
      coinType: CoinType.HB_HT,
    );

    return approveHex;
  }
}
