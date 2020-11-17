import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_detail_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:web3dart/web3dart.dart';

class TokenBurnDetailPage extends StatefulWidget {
  final BurnHistory burnHistory;

  TokenBurnDetailPage(
    this.burnHistory,
  );

  @override
  State<StatefulWidget> createState() {
    return TokenBurnDetailPageState();
  }
}

class TokenBurnDetailPageState extends BaseState<TokenBurnDetailPage> {
  List<String> _dataTitleList = [];
  List<String> _dataInfoList = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() async {
    _dataTitleList = [
      '哈希值',
      S.of(context).transfer_amount,
      '发送方',
      '接收方',
      S.of(context).description,
    ];

    _dataInfoList = [
      widget.burnHistory.hash,
      '${widget.burnHistory.getTotalAmountStr()} HYN',
      WalletUtil.ethAddressToBech32Address(widget.burnHistory.foundation),
      '0x00',
      "HYN燃烧",
    ];

    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: S.of(context).detail),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                      child: Image.asset(
                        'res/drawable/ic_transfer_account_info_success.png',
                        width: 63,
                        height: 63,
                      ),
                    ),
                    Text(
                      S.of(context).completed,
                      style: TextStyle(
                          fontSize: 16,
                          color: DefaultColors.color333,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 34),
                      child: Text(
                        FormatUtil.formatDate(
                          widget.burnHistory.timestamp,
                          isSecond: true,
                        ),
                        style: TextStyle(
                            color: DefaultColors.color999, fontSize: 13),
                      ),
                    ),
                    Container(
                      height: 11,
                      color: DefaultColors.colorf2f2f2,
                    )
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              var leftText = _dataTitleList[index];
              var rightText = _dataInfoList[index];
              if (index == 2) {
                return accountInfoItem(
                  leftText,
                  rightText,
                  hasCopy: true,
                );
              }
              return accountInfoItem(leftText, rightText);
            }, childCount: _dataTitleList.length))
          ],
        ),
      ),
    );
  }

  Widget accountInfoItem(
    String leftText,
    String rightText, {
    String bottomText,
    bool normalLine = true,
    bool hasCopy = false,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 18.0, bottom: 18, left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  leftText,
                  style: TextStyles.textC999S13,
                ),
                Spacer(),
                Container(
                  width: 198,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        rightText ?? "",
                        style: TextStyles.textC333S13,
                        textAlign: TextAlign.end,
                      ),
                      if (hasCopy)
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: rightText));
                            UiUtil.toast(S.of(context).copyed);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 7.0, left: 7, bottom: 7),
                            child: Image.asset(
                              "res/drawable/ic_copy.png",
                              width: 18,
                              height: 17,
                            ),
                          ),
                        ),
                      if (bottomText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(bottomText,
                              style: TextStyles.textC999S11,
                              textAlign: TextAlign.end),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (normalLine)
            Divider(
              color: DefaultColors.colorf2f2f2,
              indent: 15,
              endIndent: 15,
              height: 1,
            ),
          if (!normalLine)
            Container(
              height: 11,
              color: DefaultColors.colorf2f2f2,
            )
        ],
      ),
    );
  }
}
