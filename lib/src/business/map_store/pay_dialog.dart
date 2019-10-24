import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/map_store/bloc/map_store_order_bloc.dart';
import 'package:titan/src/business/map_store/bloc/map_store_order_event.dart';
import 'package:titan/src/business/map_store/bloc/map_store_order_state.dart';
import 'package:titan/src/business/map_store/map_store_api.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/vo/map_price.dart';
import 'package:titan/src/business/map_store/vo/price_policy.dart';
import 'package:titan/src/domain/firebase.dart';

class PayDialog extends StatefulWidget {
  MapStoreItem mapStoreItem;

  PayDialog({this.mapStoreItem});

  @override
  State<StatefulWidget> createState() {
    return _PayDialogState(this.mapStoreItem);
  }
}

class _PayDialogState extends State<PayDialog> {
  MapStoreApi mapStoreApi = MapStoreApi();
  MapStoreItem mapStoreItem;

  _PayDialogState(this.mapStoreItem);

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      BlocProvider.of<MapStoreOrderBloc>(context).add(BuyAppleMapEvent(mapStoreItem));
    } else if (mapStoreItem.isFree) {
      BlocProvider.of<MapStoreOrderBloc>(context).add(BuyFreeMapEvent(mapStoreItem));
    } else {
      BlocProvider.of<MapStoreOrderBloc>(context).add(ShowPayingMapPriceEvent(mapStoreItem));
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.0)));
    return BlocBuilder<MapStoreOrderBloc, MapStoreOrderState>(builder: (context, state) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Center(
            child: SizedBox(
              width: 300,
              child: Material(
                elevation: 24.0,
                color: Theme.of(context).dialogBackgroundColor,
                type: MaterialType.card,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
//                    buildWaitingView(context)
                      if (state is ShowPayingMapPriceState)
                        buildPayView(context, state.mapPrice),
                      if (state is OrderPlacingState)
                        buildPlacingOrderingView(context),
                      if (state is OrderPayingState)
                        _buildWaitingView(context),
                      if (state is OrderSuccessState)
                        _buildPaySuccessView(context),
                      if (state is OrderFailState)
                        _buildPayFailView(context),
                    ],
                  ),
                ),
                shape: _defaultDialogShape,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildPayView(BuildContext context, MapPrice mapPrice) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(
            S.of(context).service_type,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 145.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return buildPolicyView(mapPrice, mapPrice.policies[index]);
            },
            itemCount: mapPrice.policies.length,
          ),
        ),
        if (!Platform.isIOS)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              S.of(context).payment_type,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (!Platform.isIOS)
          Row(
            children: <Widget>[
              if (env.channel == BuildChannel.STORE)
                SvgPicture.asset(
                  "res/drawable/google_play.svg",
                  height: 30,
                  width: 120,
                )
              else
                SvgPicture.asset(
                  "res/drawable/alipay.svg",
                  height: 30,
                  width: 120,
                ),
              Radio(
                value: 1,
                groupValue: 1,
                onChanged: (value) {},
              )
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: <Widget>[
              RaisedButton(
                  onPressed: () async {
                    if (Navigator.of(context).canPop()) {
                      _dismissDialog(false, false);
                    }
                    BlocProvider.of<MapStoreOrderBloc>(context).add(CancelPurchaseEvent());
                    //pay success
                    await FireBaseLogic.of(context).analytics.logEvent(name: 'pay_cancel');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Text(S.of(context).cancel)),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: RaisedButton(
                  onPressed: () => _handlePay(context, mapPrice),
                  child: Text(
                    S.of(context).pay,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.purple,
                  highlightColor: Colors.purpleAccent,
                  splashColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPlacingOrderingView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Text(
          S.of(context).ordering,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 32,
        ),
        CircularProgressIndicator(),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildWaitingView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Text(
          S.of(context).waiting_for_payment_result,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 32,
        ),
        CircularProgressIndicator(),
        SizedBox(
          height: 24,
        ),
        if (env.channel != BuildChannel.STORE)
          RaisedButton(
            onPressed: () async {
              await FireBaseLogic.of(context).analytics.logEvent(name: 'pay_cancel');
              BlocProvider.of<MapStoreOrderBloc>(context).add(CancelPurchaseEvent());
              _dismissDialog(false, false);
            },
            child: Text(S.of(context).cancel_payment),
          ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _buildPaySuccessView(BuildContext context) {
    _dismissDialog(true, true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 72,
        ),
        SizedBox(
          height: 16,
        ),
        Text(S.of(context).payment_successful),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildPayFailView(BuildContext context) {
    _dismissDialog(false, true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Icon(
          Icons.error,
          color: Colors.red[700],
          size: 72,
        ),
        SizedBox(
          height: 16,
        ),
        Text(S.of(context).payment_failed),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget buildPolicyView(MapPrice mapPrice, PricePolicy pricePolicy) {
    return GestureDetector(
      onTap: () {
        print("tap");
        mapPrice.policies.forEach((pricePolicyTemp) {
          pricePolicyTemp.selected = false;
        });
        pricePolicy.selected = true;
        setState(() {});
      },
      child: Container(
        width: 140,
        height: 140,
        margin: EdgeInsets.all(4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: pricePolicy.selected ? Color(0xFFfff9de) : Colors.white,
            border: Border.all(color: pricePolicy.selected ? Color(0xFFf7da95) : Colors.grey[300], width: 3),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            Align(
                alignment: Alignment.topLeft,
                child: Text(pricePolicy.policyName, style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Row(
                children: <Widget>[
                  Text(pricePolicy.policyUnit, style: TextStyle(fontSize: 12)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Text(
                      sprintf("%.2f", [pricePolicy.policyPrice]),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(pricePolicy.policyOldPrice,
                  style: TextStyle(
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationStyle: TextDecorationStyle.solid)),
            ),
            Spacer(),
            if (pricePolicy.selected)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFf7da95), width: 1),
                      color: Color(0xFFf7da95),
                    ),
                    child: Center(child: Icon(Icons.check, color: Colors.white, size: 16))),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handlePay(BuildContext context, MapPrice mapPrice) async {
//    FireBaseLogic.of(context).analytics.logEvent(name: 'pay_comfirn', parameters: {'platform': env.channel});
    BlocProvider.of<MapStoreOrderBloc>(context).add(PurchaseEvent(mapStoreItem, mapPrice));
  }

  void _dismissDialog(bool isBuySuccess, bool isDelay) {
    if (isDelay) {
      Observable.timer("", Duration(milliseconds: 2500)).listen((token) {
        Navigator.pop(context, isBuySuccess);
      });
    } else {
      Navigator.pop(context, isBuySuccess);
    }
  }
}
