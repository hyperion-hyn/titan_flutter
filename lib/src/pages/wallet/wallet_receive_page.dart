import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/config/extends_icon_font.dart';

class WalletReceivePage extends StatelessWidget {
  final CoinVo coinVo;

  WalletReceivePage(this.coinVo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).receiver_symbol(coinVo.symbol),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                width: 224,
                decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      return InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: coinVo.address));
                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(S.of(context).address_copied)));
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              ExtendsIconFont.copy_content,
                              color: Theme.of(context).primaryColor,
                              size: 24,
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
                      Share.text(S.of(context).my_symbol_address(coinVo.symbol), coinVo.address, "text/plain");
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
      ),
    );
  }
}