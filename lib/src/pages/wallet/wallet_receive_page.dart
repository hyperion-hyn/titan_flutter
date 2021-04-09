import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

class WalletReceivePage extends StatelessWidget {
  final CoinViewVo coinVo;

  WalletReceivePage(this.coinVo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          S.of(context).receiver_symbol(coinVo.symbol),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 224,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      QrImage(
                        data: WalletUtil.formatToHynAddrIfAtlasChain(
                          coinVo,
                          coinVo.address,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[800],
                        version: 4,
                        size: 180,
                      ),
                      Text(
                        WalletUtil.formatToHynAddrIfAtlasChain(
                          coinVo,
                          coinVo.address,
                        ),
                        softWrap: true,
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      )
                    ],
                  ),
                ),
              ],
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      return InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: WalletUtil.formatToHynAddrIfAtlasChain(
                              coinVo,
                              coinVo.address,
                            ),
                          ));
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text(S.of(context).address_copied)));
                        },
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'res/drawable/ic_copy.png',
                              height: 23,
                              width: 23,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                S.of(context).copy,
                                style: TextStyle(
                                  color: HexColor(
                                    "#FF6D6D6D",
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      Share.text(
                        S.of(context).my_symbol_address(coinVo.symbol),
                        WalletUtil.formatToHynAddrIfAtlasChain(
                          coinVo,
                          coinVo.address,
                        ),
                        "text/plain",
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          ExtendsIconFont.share,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            S.of(context).share,
                            style: TextStyle(
                              color: HexColor(
                                "#FF6D6D6D",
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
           _hexAddressHInf(),
            if (coinVo.coinType == CoinType.HYN_ATLAS)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 0),
                        width: 224,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            QrImage(
                              data: coinVo.address,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[800],
                              version: 4,
                              size: 180,
                            ),
                            Text(
                              coinVo.address,
                              softWrap: true,
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Builder(
                            builder: (BuildContext context) {
                              return InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                    text: coinVo.address,
                                  ));
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(content: Text(S.of(context).address_copied)));
                                },
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'res/drawable/ic_copy.png',
                                      height: 23,
                                      width: 23,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      S.of(context).copy,
                                      style: TextStyle(
                                        color: HexColor(
                                          "#FF6D6D6D",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          InkWell(
                            onTap: () {
                              Share.text(
                                S.of(context).my_symbol_address(coinVo.symbol),
                                coinVo.address,
                                "text/plain",
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  ExtendsIconFont.share,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    S.of(context).share,
                                    style: TextStyle(
                                      color: HexColor(
                                        "#FF6D6D6D",
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _hexAddressHInf() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor('#F6FAFF'),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('在其他支持自定义RPC网络的钱包 (如: Metamask) 中，请使用以下十六进制地址: ', style: TextStyle(fontSize: 12, color: HexColor("#595B75"))),
            ],
          ),
        ),
      ),
    );
  }
}
