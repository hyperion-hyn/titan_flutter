import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';

/// 价格显示 法币选择
class MePricePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MePriceState();
  }
}

class _MePriceState extends BaseState<MePricePage> {
  LegalSign activeLegal;

  @override
  void onCreated() {
    activeLegal = WalletInheritedModel.of(context, aspect: WalletAspect.legal).activeLegal;
  }

  Widget _dividerWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
      ),
      child: Container(
        height: 0.8,
        color: HexColor('#F8F8F8'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).price_show,
        backgroundColor: Colors.white,
        showBottom: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (activeLegal != null) {
                // WalletInheritedModel.saveQuoteSign(activeLegal);
                // BlocProvider.of<WalletCmpBloc>(context).add(UpdateLegalSignEvent(sign: activeLegal));
                // BlocProvider.of<WalletCmpBloc>(context).add(UpdateQuotesEvent(isForceUpdate: true));
                BlocProvider.of<WalletCmpBloc>(context)
                    .add(UpdateLegalSignEvent(legal: activeLegal));
              }

              Navigator.pop(context);
            },
            child: Text(
              S.of(context).confirm,
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          for (var i = 0; i < SupportedLegal.all.length; i++) ...[
            _buildInfoContainer(SupportedLegal.all[i]),
            i < SupportedLegal.all.length - 1 ? _dividerWidget() : SizedBox.shrink()
          ],
        ],
      ),
    );
  }

  Widget _buildInfoContainer(LegalSign legal) {
    return InkWell(
      onTap: () {
        setState(() {
          activeLegal = legal;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 56,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                  child: Text(
                    legal.legal,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: legal.legal == activeLegal?.legal ?? '',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
