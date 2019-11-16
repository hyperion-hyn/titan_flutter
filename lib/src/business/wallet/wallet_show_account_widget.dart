import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/infomation/info_detail_page.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/wallet/etherscan_api.dart';
import 'package:titan/src/business/wallet/service/account_transfer_service.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/business/wallet/wallet_receive_page.dart';
import 'package:titan/src/business/wallet/wallet_send_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/utils/wallet_icon_utils.dart';

import 'model/transtion_detail_vo.dart';
import 'model/wallet_account_vo.dart';

class ShowAccountPage extends StatefulWidget {
  WalletAccountVo walletAccountVo;

  ShowAccountPage(this.walletAccountVo);

  @override
  State<StatefulWidget> createState() {
    return _ShowAccountPageState();
  }
}

class _ShowAccountPageState extends DataListState<ShowAccountPage> {
  static NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.####");

  static NumberFormat token_format = new NumberFormat("#,###.####");

  DateFormat dateFormat = new DateFormat("yyyy/MM/dd");

  AccountTransferService _accountTransferService = AccountTransferService();
  WalletService _walletService = WalletService();

  @override
  int getStartPage() {
    return 1;
  }

  @override
  void postFrameCallBackAfterInitState() async {
    await _walletService.updateAccountVo(widget.walletAccountVo);
    loadDataBloc.add(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "${widget.walletAccountVo.name} (${widget.walletAccountVo.symbol})",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: onWidgetLoadDataCallback,
          onRefresh: onWidgetRefreshCallback,
          onLoadingMore: onWidgetLoadingMoreCallback,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 32, bottom: 24),
                          child: Container(
                            alignment: Alignment.center,
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF9B9B9B), width: 0),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              WalletIconUtils.getIcon(widget.walletAccountVo.symbol),
                            ),
                          ),
                        ),
                        Text(
                          "${DOUBLE_NUMBER_FORMAT.format(widget.walletAccountVo.balance)} ${widget.walletAccountVo.symbol}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "≈${widget.walletAccountVo.currencyUnitSymbol} ${DOUBLE_NUMBER_FORMAT.format(widget.walletAccountVo.amount)}",
                            style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Divider(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WalletSendPage(widget.walletAccountVo)));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        ExtendsIconFont.send,
                                        color: Theme.of(context).primaryColor,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "发送",
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
                                VerticalDivider(),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WalletReceivePage(widget.walletAccountVo)));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        ExtendsIconFont.receiver,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "接收",
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
                                VerticalDivider(),
                                Builder(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: widget.walletAccountVo.account.address));
                                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("地址已复制")));
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
                                              "复制",
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
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (dataList.length > 1)
                    ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return SizedBox(
                            height: 0,
                            width: 0,
                          );
                        } else {
                          var currentTranstionDetail = dataList[index];
                          TranstionDetailVo lastTranstionDetail = null;
                          if (index > 1) {
                            lastTranstionDetail = dataList[index - 1];
                          }
                          return _buildTransactionItem(context, currentTranstionDetail, lastTranstionDetail);
                        }
                      },
                      itemCount: max<int>(0, dataList.length),
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
      iconData = ExtendsIconFont.receiver;
      title = "已收到";
      account = "From:" + shortEthAddress(transtionDetail.fromAddress);
      amountColor = HexColor("#FF259B24");
      amountText = "+ ${token_format.format(transtionDetail.amount)} ${transtionDetail.unit}";
    } else if (transtionDetail.type == TranstionType.TRANSFER_OUT) {
      iconData = ExtendsIconFont.send;
      title = "已发送";
      account = "To:" + shortEthAddress(transtionDetail.toAddress);

      amountColor = HexColor("#FFE51C23");
      amountText = "- ${token_format.format(transtionDetail.amount)} ${transtionDetail.unit}";
    }

    if(transtionDetail.toAddress.toLowerCase() == "0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07".toLowerCase()){
      title = "智能合约调用";
    }



    var time = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transtionDetail.time));
    var lastTranstionTime = lastTranstionDetail != null
        ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(lastTranstionDetail.time))
        : null;
    var isShowTime = lastTranstionTime != time;

    return Column(
      children: <Widget>[
        if (isShowTime)
          Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              color: Color(0xFFF5F5F5),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  time,
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
              )),
        InkWell(
          onTap: () {
//            var url = EtherscanApi.getTxDetailUrl(transtionDetail.hash);
//            print("txUrl:$url");
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => InfoDetailPage(
//                          url: url,
//                          title: "交易详情",
//                        )));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Icon(
                    iconData,
                    color: Color(0xFFCDCDCD),
                    size: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          account,
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
                    children: <Widget>[
                      Text(
                        amountText,
                        style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    await _walletService.updateAccountVo(widget.walletAccountVo);
    var retList = [];
    if (page == getStartPage()) {
      retList.add('header');
    }

    List<TranstionDetailVo> trasferList = [];

    try {
      trasferList = await _accountTransferService.getTransferList(widget.walletAccountVo, page);
    } catch (_) {
      logger.e(_);
    }
    retList.addAll(trasferList);
    return retList;
  }
}

class Refresh {}
