import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/business/me/model/experience_info_v2.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/style/titan_sytle.dart';

import '../../global.dart';
import 'model/contract_info_v2.dart';
import 'model/pay_order.dart';
import 'service/user_service.dart';

class PurchaseContractPage extends StatefulWidget {
  final ContractInfoV2 contractInfo;

  PurchaseContractPage({@required this.contractInfo});

  @override
  State<StatefulWidget> createState() {
    return _PurchaseContractState();
  }
}

class _PurchaseContractState extends State<PurchaseContractPage> {
  var service = UserService();

  ExperienceInfoV2 experienceInfo = ExperienceInfoV2(0, 0);
  PayOrder payOrder;

  TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _descController.dispose();
  }

  void loadData() async {
    //体验信息
    experienceInfo = await service.experience(widget.contractInfo.id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).experience_contract_mortgage,
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), shape: BoxShape.rectangle),
              child: Column(
                children: <Widget>[],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )),
                      child: Row(
                        children: <Widget>[
                          Text(S.of(context).select_contract_quantity),
                          Spacer(),
                        ],
                      )),
                  _buildHynBalancePayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHynBalancePayBox() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildInputCell(),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: RaisedButton(
                  elevation: 1,
                  color: Color(0xFFD6A734),
                  onPressed: _onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: SizedBox(
                        height: 40,
                        width: 192,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (_isOnPressed)
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Loading(
                                      indicator: BallSpinFadeLoaderIndicator(),
                                    )),
                              ),
                            Text(
                              S.of(context).next,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ))),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 10),
          child: Text(
            S.of(context).input_contract_quantity,
            style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 45, top: 6, bottom: 10),
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
            child: TextFormField(
              controller: _descController,
              validator: (value) {
                if (value == null || value.trim().length == 0) {
                  return S.of(context).experience_numbers_not_empty;
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.number,
              maxLength: null,
              maxLines: null,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).experience_upper_func(experienceInfo.canBuy.toString()),
                hintStyle: TextStyle(fontSize: 14, color: DefaultColors.color777),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isOnPressed = false;
  void _onPressed() async {
    var countText = _descController.text;
    if (countText.isEmpty) {
      Fluttertoast.showToast(msg: S.of(context).experience_numbers_not_empty, gravity: ToastGravity.CENTER);
      return;
    }

    if (_isOnPressed) {
      return;
    }
    setState(() {
      _isOnPressed = true;
    });

    try {
      payOrder = await service.createExperienceOrder(contractId: widget.contractInfo.id, count: int.parse(countText));
    } catch (e) {
      logger.e(e);
      setState(() {
        _isOnPressed = false;
      });
      if (e is HttpResponseCodeNotSuccess) {
        if (e.code == -1007) {
          Fluttertoast.showToast(msg: S.of(context).over_limit_amount_hint);
        } else if (e.code == -1004) {
          Fluttertoast.showToast(msg: S.of(context).balance_lack);
        } else {
          Fluttertoast.showToast(msg: e.message ?? S.of(context).pay_fail_hint);
        }
        return;
      }
    }

    setState(() {
      _isOnPressed = false;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PurchasePage(
                  contractInfo: widget.contractInfo,
                  payOrder: payOrder,
              number: countText,
                )));
  }
}
