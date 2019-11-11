import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallet_manager/wallet_manager.dart';
import 'package:titan/src/business/wallet/wallet_show_account_widget.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/utils/wallet_icon_utils.dart';

import 'model/wallet_account_vo.dart';
import 'model/wallet_vo.dart';

class ShowWallet extends StatefulWidget {
  WalletVo wallet;

  ShowWallet(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _ShowWalletState();
  }
}

class _ShowWalletState extends State<ShowWallet> {
  WalletVo wallet;

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  @override
  void initState() {
    super.initState();
    wallet = widget.wallet;
  }

  @override
  Widget build(BuildContext context) {
    KeyStore walletKeyStore = wallet.wallet.keystore;
    var walletName = walletKeyStore.name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 16),
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${wallet.amountUnit}",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 16),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "\$",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${DOUBLE_NUMBER_FORMAT.format(wallet.amount)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletManagerPage(),
                                  settings: RouteSettings(name: "/wallet_manager_page")));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "${walletName}",
                              style: TextStyle(color: Color(0xFF252525)),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9B9B9B),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowAccountPage(wallet.accountList[index]),
                              settings: RouteSettings(name: "/show_account_page")));
                    },
                    child: _buildAccountItem(context, wallet.accountList[index]));
              },
              itemCount: wallet.accountList.length,
            )
          ]),
    );
  }

  Widget _buildAccountItem(BuildContext context, WalletAccountVo account) {
    var iconUrl = WalletIconUtils.getIcon(account.symbol);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9B9B9B), width: 0),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              iconUrl,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  account.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${account.currencyUnit} ${DOUBLE_NUMBER_FORMAT.format(account.currencyRate)}",
                    style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "${DOUBLE_NUMBER_FORMAT.format(account.count)} ${account.symbol}",
                  style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${account.currencyUnit} ${DOUBLE_NUMBER_FORMAT.format(account.amount)}",
                    style: TextStyle(fontSize: 14, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
