import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/etherscan_api.dart';
import 'package:titan/src/business/wallet/model/erc20_transfer_history.dart';
import 'package:titan/src/business/wallet/model_vo.dart';
import 'package:titan/src/business/wallet/wallet_receive_page.dart';
import 'package:titan/src/business/wallet/wallet_send_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/utils.dart';

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
  List<TranstionDetailVo> _transtionDetails = [];

  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.##");

  EtherscanApi _etherscanApi = EtherscanApi();

  DateFormat dateFormat = new DateFormat("yy/MM/dd");

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _currentPage = 0;

  @override
  void initState() {
    _getTransferList(0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.walletAccountVo.name} Token"),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          footer: ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            completeDuration: Duration(milliseconds: 500),
          ),
          header: WaterDropHeader(),
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 1000));
            await _getTransferList(0);
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await Future.delayed(Duration(milliseconds: 1000));
            await _getTransferList(_currentPage + 1);
            _refreshController.loadComplete();
          },
          child: SingleChildScrollView(
            child: Column(
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
                            "≈${widget.walletAccountVo.currencyUnit}${DOUBLE_NUMBER_FORMAT.format(widget.walletAccountVo.amount)}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => WalletSendPage(widget.walletAccountVo)));
                                },
                                child: Column(
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
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WalletReceivePage(widget.walletAccountVo)));
                                },
                                child: Column(
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
                              ),
                              Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: widget.walletAccountVo.account.address));
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text("地址已复制")));
                                    },
                                    child: Column(
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
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      var currentTranstionDetail = _transtionDetails[index];
                      TranstionDetailVo lastTranstionDetail = null;
                      if (index > 0) {
                        lastTranstionDetail = _transtionDetails[index - 1];
                      }
                      return _buildTransactionItem(context, currentTranstionDetail, lastTranstionDetail);
                    },
                    itemCount: _transtionDetails.length,
                  )
                ]),
          ),
        ));
  }

  Widget _buildTransactionItem(
      BuildContext context, TranstionDetailVo transtionDetail, TranstionDetailVo lastTranstionDetail) {
    var iconData = null;
    var title = "";
    var account = "";
    var amountColor = null;
    var amountText = null;
    if (transtionDetail.type == TranstionType.TRANSFER_IN) {
      iconData = Icons.arrow_downward;
      title = "已收到";
      account = "From:" + shortEthAddress(transtionDetail.fromAddress);
      amountColor = HexColor("#FF259B24");
      amountText = "+${transtionDetail.amount}${transtionDetail.unit}";
    } else if (transtionDetail.type == TranstionType.TRANSFER_OUT) {
      iconData = Icons.arrow_upward;
      title = "已发送";
      account = "To:" + shortEthAddress(transtionDetail.toAddress);

      amountColor = HexColor("#FFE51C23");
      amountText = "-${transtionDetail.amount}${transtionDetail.unit}";
    }

    var time = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transtionDetail.time));
    var lastTranstionTime = lastTranstionDetail != null
        ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(lastTranstionDetail.time))
        : null;
    var isShowTime = lastTranstionTime != time;

    return Column(
      children: <Widget>[
        if(isShowTime)
          Column(
            children: <Widget>[
              Divider(
                thickness: 1.5,
                height: 2,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(time),
                  )),
              Divider(
                thickness: 1.5,
                height: 2,
              ),
            ],
          ),
        Padding(
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
        ),
      ],
    );
  }

  Future _getTransferList(int page) async {
    var contractAddress = widget.walletAccountVo.assetToken.erc20ContractAddress;

    List<Erc20TransferHistory> erc20TransferHistoryList =
        await _etherscanApi.queryErc20History(contractAddress, widget.walletAccountVo.account.address, page);

    List<TranstionDetailVo> detailList = erc20TransferHistoryList.map((erc20TransferHistory) {
      var type = 0;
      if (erc20TransferHistory.from == widget.walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_OUT;
      } else if (erc20TransferHistory.to == widget.walletAccountVo.account.address.toLowerCase()) {
        type = TranstionType.TRANSFER_IN;
      }
      return TranstionDetailVo(
          type: type,
          state: 0,
          amount: Convert.weiToNum(BigInt.parse(erc20TransferHistory.value)).toDouble(),
          unit: erc20TransferHistory.tokenSymbol,
          fromAddress: erc20TransferHistory.from,
          toAddress: erc20TransferHistory.to,
          time: int.parse(erc20TransferHistory.timeStamp + "000"));
    }).toList();
    if (page == 0) {
      _transtionDetails.clear();
      _transtionDetails.addAll(detailList);
    } else {
      if (detailList.length == 0) {
        return;
      }
      _transtionDetails.addAll(detailList);
    }
    _currentPage = page;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class TranstionDetailVo {
  int type; //1、转出 2、转入
  int state;
  double amount;
  String unit;
  String fromAddress;
  String toAddress;
  int time;

  TranstionDetailVo({this.type, this.state, this.amount, this.unit, this.fromAddress, this.toAddress, this.time});
}

class TranstionType {
  static const TRANSFER_OUT = 1;
  static const TRANSFER_IN = 2;
}

class Refresh {}
