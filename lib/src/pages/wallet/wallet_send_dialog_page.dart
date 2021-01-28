import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletSendDialogPage extends StatefulWidget {
  final WalletSendDialogEntity entity;
  WalletSendDialogPage({
    @required this.entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _WalletSendDialogState();
  }
}

class _WalletSendDialogState extends BaseState<WalletSendDialogPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Widget widget1 = Container();
    Widget widget2 = Container();

    if ((widget.entity.value ?? 0) > 0 && (widget.entity.value1 ?? 0) > 0) {
      widget1 = _rowText(
        title: S.of(context).transfer_gas_fee,
        content: '${widget.entity.gas} ${widget.entity.gasUnit}',
        subContent: widget.entity.gasDesc,
        showLine: false,
      );

      widget2 = _rowText(
        title: '',
        content: '${widget.entity.gas1} ${widget.entity.gasUnit}',
        subContent: widget.entity.gas1Desc,
        showLine: false,
      );
    } else {
      if ((widget.entity.value ?? 0) > 0) {
        widget1 = _rowText(
          title: S.of(context).transfer_gas_fee,
          content: '${widget.entity.gas} ${widget.entity.gasUnit}',
          subContent: widget.entity.gasDesc,
          showLine: false,
        );
      }
    }

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
                          // SizedBox(height: 200,),
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
                                  color: HexColor('#E7C01A'),
                                ),
                              ),
                            ],
                          ),
                          if ((widget.entity?.value ?? 0) > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                  ),
                                  child: Text(
                                    '${widget.entity?.value ?? '0'} ${widget.entity.valueUnit}',
                                    style: TextStyle(
                                      color: HexColor('#333333'),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if ((widget.entity?.value1 ?? 0) > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                  ),
                                  child: Text(
                                    '${widget.entity?.value1 ?? '0'} ${widget.entity.value1Unit}',
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
                            content: widget.entity.title,
                          ),
                          _rowText(
                            title: S.of(context).exchange_from,
                            content: widget.entity.fromName,
                            subContent: widget.entity.fromAddress,
                          ),
                          _rowText(
                            title: S.of(context).exchange_to,
                            content: widget.entity.toName,
                            subContent: widget.entity.toAddress,
                          ),
                          widget1,
                          widget2,
                        ],
                      ),
                    ),
                  ),
                  ClickOvalButton(
                    S.of(context).send,
                    _sendAction,
                    btnColor: [HexColor("#E7C01A"), HexColor("#F7D33D")],
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
                  (subContent?.isEmpty ?? true) ? '' : '（$subContent）',
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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    bool isFinish = await widget.entity.action();
    print("[$runtimeType] _sendAction, isFinish:$isFinish");

    if (isFinish) {
      Navigator.of(context).pop();

      widget.entity.finished();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<bool> showWalletSendDialog<T>({
  @required BuildContext context,
  @required WalletSendDialogEntity entity,
}) {
  return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return WalletSendDialogPage(
          entity: entity,
        );
      });
}

typedef WalletSendEntityCallBack = Future<bool> Function();

class WalletSendDialogEntity {
  final String type;
  final double value;
  final double value1;
  final String valueUnit;
  final String value1Unit;
  final String title;
  final String fromName;
  final String fromAddress;
  final String toName;
  final String toAddress;
  final String gas;
  final String gas1;
  final String gasDesc;
  final String gas1Desc;
  final String gasUnit;

  final WalletSendEntityCallBack action;
  final WalletSendEntityCallBack finished;

  WalletSendDialogEntity({
    this.type,
    this.value,
    this.value1,
    this.valueUnit,
    this.value1Unit,
    this.title,
    this.fromName,
    this.fromAddress,
    this.toName,
    this.toAddress,
    this.gas,
    this.gas1,
    this.gasDesc,
    this.gas1Desc,
    this.gasUnit,
    this.action,
    this.finished,
  });
}

/*

交易信息：
1、转账 （完成）
2、节点调用(创建共识节点，编辑共识节点，复抵押，撤销复抵押，代领出块奖励； 创建Map3节点，编辑Map3节点，终止Map3节点，微抵押，撤销微抵押，提取Map3奖励，变更自动续约)
3、智能合约调用（提升量级，抵押传导，发红包。。。）
*/
