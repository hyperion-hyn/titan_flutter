import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpTransferConfirmDialog extends StatelessWidget {
  final String hynAmount;
  final String rpAmount;
  final String hynFee;
  final String rpFee;
  final ScrollController _scrollController = ScrollController();

  RpTransferConfirmDialog({
    this.hynAmount = '0',
    this.rpAmount = '0',
    this.hynFee = '0',
    this.rpFee = '0',
  });

  @override
  Widget build(BuildContext context) {
    var walletVo = WalletInheritedModel.of(context).activatedWallet;
    var walletName = walletVo.wallet.keystore.name;
    var hynAddress = WalletUtil.ethAddressToBech32Address(walletVo.wallet.getAtlasAccount().address);
    var walletAddress = shortBlockChainAddress(hynAddress);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 14,
                                ),
                                child: Text(
                                  '转账确认',
                                  style: TextStyle(
                                    color: HexColor('#999999'),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 32,
                                ),
                                child: Image.asset(
                                  'res/drawable/rp_share_send.png',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  // color: HexColor('#FF1F81FF'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                ),
                                child: Text(
                                  '$rpAmount RP',
                                  style: TextStyle(
                                    color: HexColor('#333333'),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: Text(
                                  '$hynAmount HYN',
                                  style: TextStyle(
                                    color: HexColor('#333333'),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          _rowText(
                            title: '交易信息',
                            content: '发红包',
                          ),
                          _rowText(
                            title: S.of(context).exchange_from,
                            content: walletName,
                            subContent: walletAddress,
                          ),
                          _rowText(
                            title: S.of(context).exchange_to,
                            content: S.of(context).rp_red_pocket,
                          ),
                          _rowText(
                            title: S.of(context).transfer_gas_fee,
                            content: '$rpFee HYN',
                            subContent: 'RP 产生',
                            showLine: false,
                          ),
                          _rowText(
                            title: '',
                            content: '$hynFee HYN',
                            subContent: 'HYN 产生',
                            showLine: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClickOvalButton(
                    S.of(context).send,
                    () async {
                      var password = await UiUtil.showWalletPasswordDialogV2(context, walletVo.wallet);
                      if (password == null) {
                        return;
                      }
                    },
                    btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                    fontSize: 16,
                    width: 260,
                    height: 42,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Image.asset(
                  'res/drawable/rp_share_close.png',
                  width: 12,
                  height: 12,
                  fit: BoxFit.cover,
                  // color: HexColor('#FF1F81FF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowText({String title = '', String content = '', String subContent = '', bool showLine = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: title.isNotEmpty ? 20 : 2,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: HexColor('#999999'),
                    ),
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#333333'),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subContent.isEmpty ? '' : '（$subContent）',
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#999999'),
                  ),
                ),
              ],
            ),
          ),
          if (showLine)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 0.5,
              color: HexColor('#F2F2F2'),
            ),
        ],
      ),
    );
  }
}
