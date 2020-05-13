import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';

class MePricePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MePriceState();
  }
}

class _MePriceState extends State<MePricePage> {
  @override
  void initState() {
    super.initState();
  }

  var activeQuotesSign;

  @override
  Widget build(BuildContext context) {
    if (activeQuotesSign == null) {
      activeQuotesSign = QuotesInheritedModel.of(context,aspect: QuotesAspect.quote).activeQuotesSign;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).price_show,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          InkWell(
            onTap: () {
              BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(quotesSign: activeQuotesSign));
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).confirm,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: ListView(
          children: SupportedQuoteSigns.all.map<Widget>((quotesSign) {
        return _buildInfoContainer(quotesSign);
      }).toList()),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
      ),
    );
  }

  Widget _buildInfoContainer(QuotesSign quotesSign) {
    return InkWell(
      onTap: () {
        setState(() {
          activeQuotesSign = quotesSign;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                  child: Text(
                    quotesSign.quote,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: quotesSign.quote == activeQuotesSign.quote,
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
          _divider()
        ],
      ),
    );
  }
}
