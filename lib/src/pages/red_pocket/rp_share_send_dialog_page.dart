import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_location_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_send_dialog_page.dart';
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
    title: '发红包',
    fromName: walletName,
    fromAddress: fromAddress,
    toName: S.of(context).rp_red_pocket,
    toAddress: toAddress,
    gas: '0.0001',
    gas1: '0.0001',
    gasDesc: 'HYN 产生',
    gas1Desc: 'RP 产生',
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
