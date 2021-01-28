/*

交易信息：
1、转账 （完成）
2、节点调用(创建共识节点，编辑共识节点，复抵押，撤销复抵押，代领出块奖励； 创建Map3节点，编辑Map3节点，终止Map3节点，微抵押，撤销微抵押，提取Map3奖励，变更自动续约)
3、智能合约调用（提升量级，抵押传导，发红包。。。）
*/

import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utils.dart';

class WalletModelUtil {
  static WalletInheritedModel get walletModel =>
      WalletInheritedModel.of(Keys.rootKey.currentContext);

  static CoinViewVo get rpCoinVo => walletModel.getCoinVoBySymbol('RP');

  static get activatedWallet => walletModel.activatedWallet;

  static get wallet => activatedWallet.wallet;

  static get walletName => activatedWallet?.wallet?.keystore?.name ?? '';

  static get walletEthAddress => activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  static get walletHynShortAddress {
    var hynAddress = WalletUtil.ethAddressToBech32Address(
        activatedWallet?.wallet?.getEthAccount()?.address ?? "");
    var address = shortBlockChainAddress(hynAddress);
    return address;
  }
}
