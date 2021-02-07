import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_location_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_dialog_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utils.dart';

Future<bool> showShareRpSendDialog<T>(
  BuildContext context,
  RpShareReqEntity reqEntity,
) {
  var walletVo = WalletInheritedModel.of(context).activatedWallet;
  var wallet = walletVo.wallet;

  var walletName = wallet.keystore.name;

  var address = wallet.getAtlasAccount().address;
  var fromAddressHyn = WalletUtil.ethAddressToBech32Address(address);
  var fromAddress = shortBlockChainAddress(fromAddressHyn);

  var rpShareConfig = RedPocketInheritedModel.of(context).rpShareConfig;
  var receiveAddr = rpShareConfig?.receiveAddr ?? '';
  var toAddress;
  if (receiveAddr.isEmpty) {
    Fluttertoast.showToast(msg: S.of(context).net_error_please_again);
  } else {
    // var toAddressHyn = WalletUtil.ethAddressToBech32Address(receiveAddr);
    // toAddress = shortBlockChainAddress(toAddressHyn);
  }

  WalletSendDialogEntity entity = WalletSendDialogEntity(
    type: 'tx_send_share_rp',
    value: reqEntity.hynAmount,
    value1: reqEntity.rpAmount,
    valueUnit: 'HYN',
    value1Unit: 'RP',
    title: S.of(context).send_red_pocket,
    fromName: walletName,
    fromAddress: fromAddress,
    toName: S.of(context).rp_red_pocket,
    toAddress: toAddress,
    gas: ConvertTokenUnit.weiToEther(weiInt: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
        .systemConfigEntity
        .ethTransferGasLimit).toString(),
    gas1: ConvertTokenUnit.weiToEther(weiInt: SettingInheritedModel.ofConfig(Keys.rootKey.currentContext)
        .systemConfigEntity
        .erc20TransferGasLimit).toString(),
    gasDesc: 'HYN ${S.of(context).rp_send_dialog_gas_create}',
    gas1Desc: 'RP ${S.of(context).rp_send_dialog_gas_create}',
    gasUnit: 'HYN',
    action: (String password) async {
      var coinVo = WalletInheritedModel.of(Keys.rootKey.currentContext).getCoinVoBySymbol('RP');

      RpShareReqEntity result = await RPApi().postSendShareRp(
        password: password,
        activeWallet: walletVo,
        reqEntity: reqEntity,
        toAddress: receiveAddr,
        coinVo: coinVo,
      );
      reqEntity.id = result.id;
      return result.id.isNotEmpty;
    },
    finished: (String _) async {
      if (reqEntity.rpType == RpShareType.normal) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpShareSendSuccessPage(
              reqEntity: reqEntity,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpShareSendSuccessLocationPage(),
          ),
        );
      }
      return true;
    },
  );

  return showWalletSendDialog(
    context: context,
    entity: entity,
  );
}
