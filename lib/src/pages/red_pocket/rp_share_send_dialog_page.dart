import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpShareSendDialogPage extends StatefulWidget {
  final RpShareReqEntity reqEntity;
  RpShareSendDialogPage({this.reqEntity});

  @override
  State<StatefulWidget> createState() {
    return _RpShareSendDialogState();
  }
}

class _RpShareSendDialogState extends BaseState<RpShareSendDialogPage> {
  final ScrollController _scrollController = ScrollController();
  final RPApi _rpApi = RPApi();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var walletVo = WalletInheritedModel.of(context).activatedWallet;
    var wallet = walletVo.wallet;
    var address = wallet.getAtlasAccount().address;

    var walletName = wallet.keystore.name;
    var hynAddress = WalletUtil.ethAddressToBech32Address(address);
    var walletAddress = shortBlockChainAddress(hynAddress);
    var rpFee = '0.0001';
    var hynFee = '0.0001';

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 100),
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
                                  '${widget.reqEntity?.rpAmount ?? '0'} RP',
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
                                  '${widget.reqEntity?.hynAmount ?? '0'} HYN',
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
                    _sendAction,
                    btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                    fontSize: 16,
                    width: 260,
                    height: 42,
                    isLoading: _isLoading,
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

  Widget _rowText({
    String title = '',
    String content = '',
    String subContent = '',
    bool showLine = true,
  }) {
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

  void _sendAction() async {
    var walletVo = WalletInheritedModel.of(context).activatedWallet;
    var wallet = walletVo.wallet;
    var password = await UiUtil.showWalletPasswordDialogV2(context, wallet);
    if (password == null) {
      return;
    }

    var rpShareConfig = RedPocketInheritedModel.of(context).rpShareConfig;
    var toAddress = rpShareConfig?.receiveAddr ?? '';
    if (toAddress.isEmpty) {
      Fluttertoast.showToast(msg: '网络异常，请稍后重试!');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    var coinVo = WalletInheritedModel.of(Keys.rootKey.currentContext).getCoinVoBySymbol('RP');
    print("【$runtimeType】postSendShareRp， 1");

    try {
      RpShareReqEntity result = await _rpApi.postSendShareRp(
        password: password,
        activeWallet: walletVo,
        reqEntity: widget.reqEntity,
        toAddress: toAddress,
        coinVo: coinVo,
      );

      print("[$runtimeType] postSendShareRp, 2, result:${result.toJson()}");

      if (result.id.isNotEmpty) {
        widget.reqEntity.id = result.id;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpShareSendSuccessPage(
              reqEntity: widget.reqEntity,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: '发送红包失败！');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

Future<bool> showShareRpSendDialog<T>(
  BuildContext context,
  RpShareReqEntity reqEntity,
) {
  return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return RpShareSendDialogPage(
          reqEntity: reqEntity,
        );
      });

/*  return showDialog<bool>(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return RpShareSendDialogPage(
        reqEntity: reqEntity,
      );
    },
  );*/
}
