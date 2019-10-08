import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/model_vo.dart';

import 'wallert_create_new_account_page.dart';
import 'wallert_import_account_page.dart';

class ShowAccountPage extends StatefulWidget {
  final WalletAccountVo walletAccountVo;
  ShowAccountPage(this.walletAccountVo);
  @override
  State<StatefulWidget> createState() {
    return _ShowAccountPageState();
  }
}

class _ShowAccountPageState extends State<ShowAccountPage> {
  List<TranstionDetail> _transtionDetails = [
    TranstionDetail(
        type: TranstionType.TRANSFER_IN,
        state: 1,
        amount: 12,
        unit: "HYN",
        fromAddress: "3423432134124341324321432432",
        toAddress: "431434123432143434"),
    TranstionDetail(
        type: TranstionType.TRANSFER_OUT,
        state: 1,
        amount: 12,
        unit: "HYN",
        fromAddress: "3423432134124341324321432432",
        toAddress: "431434123432143434")
  ];

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.walletAccountVo.name} Token"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text("${widget.walletAccountVo.symbol}"),
                      ),
                    ),
                    Text(
                      "${DOUBLE_NUMBER_FORMAT.format(widget.walletAccountVo.count)}${widget.walletAccountVo.symbol}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "≈${widget.walletAccountVo.priceUnit}${DOUBLE_NUMBER_FORMAT.format(widget.walletAccountVo.amount)}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: HexColor("#FF3F51B5"),
                                  border: Border.all(color: Colors.grey, width: 0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "发送",
                                  style: TextStyle(
                                    color: HexColor(
                                      "#FF3F51B5",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: HexColor("#FF3F51B5"),
                                  border: Border.all(color: Colors.grey, width: 0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "接收",
                                  style: TextStyle(
                                    color: HexColor(
                                      "#FF3F51B5",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: HexColor("#FF3F51B5"),
                                  border: Border.all(color: Colors.grey, width: 0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.content_copy,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "复制",
                                  style: TextStyle(
                                    color: HexColor(
                                      "#FF3F51B5",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1.5,
                height: 2,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text("2019/12/3"),
                  )),
              Divider(
                thickness: 1.5,
                height: 2,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return _buildTransactionItem(context, _transtionDetails[index]);
                },
                itemCount: _transtionDetails.length,
              )
            ]));
  }

  Widget _buildTransactionItem(BuildContext context, TranstionDetail transtionDetail) {
    var iconData = null;
    var title = "";
    var account = "";
    var amountColor = null;
    var amountText = null;
    if (transtionDetail.type == TranstionType.TRANSFER_IN) {
      iconData = Icons.arrow_downward;
      title = "已收到";
      account = "From:" + transtionDetail.fromAddress;
      amountColor = HexColor("#FF259B24");
      amountText = "+${transtionDetail.amount}${transtionDetail.unit}";
    } else if (transtionDetail.type == TranstionType.TRANSFER_OUT) {
      iconData = Icons.arrow_upward;
      title = "已发送";
      account = "To:" + transtionDetail.toAddress;

      amountColor = HexColor("#FFE51C23");
      amountText = "-${transtionDetail.amount}${transtionDetail.unit}";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    account,
                    style: TextStyle(fontSize: 12, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  amountText,
                  style: TextStyle(color: amountColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TranstionDetail {
  int type; //1、转出 2、转入
  int state;
  double amount;
  String unit;
  String fromAddress;
  String toAddress;

  TranstionDetail({this.type, this.state, this.amount, this.unit, this.fromAddress, this.toAddress});
}

class TranstionType {
  static const TRANSFER_OUT = 1;
  static const TRANSFER_IN = 2;
}
