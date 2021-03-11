import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/pages/wallet/api/hb_api.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utils.dart';

import 'model/transaction_info_vo.dart';
import 'model/wallet_send_dialog_util.dart';

class TxInfoItem extends StatefulWidget {
  final TransactionInfoVo txInfo;

  TxInfoItem(this.txInfo);

  @override
  State<StatefulWidget> createState() {
    return _TxInfoItemState();
  }
}

class _TxInfoItemState extends State<TxInfoItem> {
  AccountTransferService _accountTransferService = AccountTransferService();

  @override
  void initState() {
    super.initState();
    _updateTxStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TxInfoItem oldWidget) {
    _updateTxStatus();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iconPath = '';
    var title = "";
    var describe = "";
    var amountText = "";
    var amountSubText = "";
    amountText = "${FormatUtil.formatCoinNum(double.tryParse(widget.txInfo.amount))}";

    if (widget.txInfo.status == 0) {
      title = S.of(context).pending;
    } else if (widget.txInfo.status == 1) {
      title = S.of(context).completed;
    } else if (widget.txInfo.status == 2) {
      title = S.of(context).wallet_fail_title;
    }

    var limitLength = 4;

    if (WalletModelUtil.walletEthAddress == widget.txInfo.toAddress) {
      amountText = '+$amountText';
      iconPath = "res/drawable/ic_wallet_account_list_receiver.png";
      describe = "From: " +
          shortBlockChainAddress(widget.txInfo.fromAddress, limitCharsLength: limitLength);
    } else if (WalletModelUtil.walletEthAddress == widget.txInfo.fromAddress) {
      amountText = '-$amountText';
      iconPath = "res/drawable/ic_wallet_account_list_send.png";
      describe =
          "To: " + shortBlockChainAddress(widget.txInfo.toAddress, limitCharsLength: limitLength);
    }

    var time = DateFormat("HH:mm MM/dd").format(
      DateTime.fromMillisecondsSinceEpoch(widget.txInfo.time),
    );

    return Ink(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 18,
          ),
          Ink(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                HbApi.jumpToScanByHash(context, widget.txInfo.hash);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      iconPath,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                amountText,
                                style: TextStyle(
                                    color: DefaultColors.color333,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (amountSubText.isNotEmpty)
                                Text(
                                  amountSubText,
                                  style: TextStyle(
                                    color: DefaultColors.color999,
                                    fontSize: 12,
                                  ),
                                ),
                              Spacer(),
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: DefaultColors.color333,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  describe,
                                  style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                                ),
                              ),
                              Spacer(),
                              Text(
                                time,
                                style: TextStyle(
                                  color: DefaultColors.color999,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    Image.asset(
                      "res/drawable/add_position_image_next.png",
                      height: 13,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 18.0),
          Divider(
            height: 1,
            indent: 21,
            endIndent: 21,
          )
        ],
      ),
    );
  }

  _updateTxStatus() async {
    if (widget.txInfo.status == TxInfoStatus.PENDING.index) {
      try {
        final client = WalletUtil.getWeb3Client(CoinType.HB_HT);
        var receipt = await client.getTransactionReceipt(widget.txInfo.hash);
        if (receipt != null) {
          ///update ui
          widget.txInfo.status =
              receipt.status ? TxInfoStatus.SUCCESS.index : TxInfoStatus.FAIL.index;

          ///update tx-info in db
          await Injector.of(context)
              .repository
              .txInfoDao
              .insertOrUpdate(widget.txInfo.copyWith(widget.txInfo));
        }
        if (mounted) setState(() {});
      } catch (e) {
        LogUtil.toastException(e);
      }
    }
  }
}
