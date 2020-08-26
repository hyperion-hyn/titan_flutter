import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';

class AtlasNodeCreateConfirmPage extends StatefulWidget {
  final CreateAtlasPayload _createAtlasPayload;

  AtlasNodeCreateConfirmPage(
    this._createAtlasPayload,
  );

  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeCreateConfirmPageState();
  }
}

class _AtlasNodeCreateConfirmPageState
    extends BaseState<AtlasNodeCreateConfirmPage> {
  var isTransferring = false;
  var isLoadingGasFee = false;

  WalletVo _activatedWallet;

  @override
  void onCreated() {
    _activatedWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          '确认创建Atlas节点',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          ExtendsIconFont.send,
                          color: Theme.of(context).primaryColor,
                          size: 48,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8),
                          child: Text(
                            "- 0 HYN",
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          "≈ 100",
                          style:
                              TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "From",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: '钱包',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: DefaultColors.color333,
                                      )),
                                  TextSpan(
                                    text:
                                        '${_activatedWallet.wallet.keystore.name} (${shortBlockChainAddress(_activatedWallet.wallet.getEthAccount().address)})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: DefaultColors.color999,
                                    ),
                                  )
                                ],
                              ),
                              maxLines: 2,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "To",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: 'Atlas节点',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DefaultColors.color333,
                                )),
                            TextSpan(text: '  '),
                            TextSpan(
                                text: '节点号： PB2020',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DefaultColors.color999,
                                )),
                          ])),
                        )
                      ],
                    )
                  ],
                ),
              ),
              _divider(),
              SizedBox(
                height: 36,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '矿工费',
                          style: TextStyle(
                            fontSize: 14,
                            color: DefaultColors.color333,
                          )),
                      TextSpan(text: '  '),
                      TextSpan(
                          text: '0.00005HYN',
                          style: TextStyle(
                            fontSize: 14,
                            color: DefaultColors.color999,
                          )),
                    ]))
                  ],
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: isTransferring ? null : _transfer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          isTransferring ? S.of(context).please_waiting : '提交',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 2,
      ),
    );
  }

  _transfer() {
    _broadcastSuccess();
  }

  _broadcastSuccess() {
    Application.router.navigateTo(
        context,
        Routes.atlas_broadcast_success_page +
            "?actionEvent=${AtlasNodeActionEvent.CREATE}");
  }
}
