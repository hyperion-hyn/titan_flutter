import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/account/account_component.dart';
import 'package:titan/src/components/account/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/mine/me_account_bind_request.dart';
import 'package:titan/src/pages/mine/promote_qr_code_page.dart';
import 'package:titan/src/pages/red_pocket/rp_friend_invite_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/popup/bubble_widget.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';
import 'api/contributions_api.dart';
import 'model/account_bind_info_entity.dart';
import 'model/user_info.dart';

class MeAccountBindPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeAccountBindState();
  }
}

class _MeAccountBindState extends BaseState<MeAccountBindPage> with RouteAware {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  UserInfo _userInfo;
  AccountBindInfoEntity _accountBindInfoEntity;
  ContributionsApi _api = ContributionsApi();
  final _addressKey = GlobalKey<FormState>();
  final TextEditingController _addressEditController = TextEditingController();

  String get _address =>
      WalletInheritedModel.of(Keys.rootKey.currentContext)
          ?.activatedWallet
          ?.wallet
          ?.getEthAccount()
          ?.address ??
      "";

  String get _shortAddress {
    var beach32Address = WalletUtil.ethAddressToBech32Address(_address ?? '');
    var address = shortBlockChainAddress(
      beach32Address,
    );
    return address;
  }

  get _flatTextStyle => TextStyle(
        color: HexColor("#1F81FF"),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  get _contentTextStyle => TextStyle(
        color: HexColor("#333333"),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  get _titleTextStyle => TextStyle(
        color: HexColor("#333333"),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  String _defaultEmptyText = S.of(Keys.rootKey.currentContext).not_bind;
  String _cancelTitle = S.of(Keys.rootKey.currentContext).cancel_bind;

  // var _moreKey = GlobalKey(debugLabel: '__more_global__');
  // double _moreSizeHeight = 18;

  // 0: 游客，1: 主账号，2: 子账号
  int get accountType {
    if (_accountBindInfoEntity?.isMaster ??
        false ||
            (_accountBindInfoEntity?.subRelationships?.isNotEmpty ?? false)) {
      return 1;
    } else if ((_accountBindInfoEntity?.request != null &&
            (_accountBindInfoEntity?.request?.state ?? 0) != -3) ||
        (_accountBindInfoEntity?.isSub ?? false)) {
      return 2;
    }
    return 0;
  }

  int get accountType1 {
    if (_accountBindInfoEntity?.isMaster ?? false) {
      return 1;
    } else if (_accountBindInfoEntity?.isSub ?? false) {
      return 2;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() async {
    _syncData();

    loadDataBloc.add(LoadingEvent());

    super.onCreated();
  }

  Future _syncData() async {
    if (context == null) return;

    _userInfo =
        AccountInheritedModel.of(context, aspect: AccountAspect.userInfo)
            ?.userInfoModel;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPopNext() {
    loadDataBloc.add(LoadingEvent());

    super.didPushNext();
  }

  void getNetworkData() async {
    try {
      _accountBindInfoEntity = await _api.getMrInfo();

      if (context != null) {
        BlocProvider.of<AccountBloc>(context).add(UpdateUserInfoEvent());
      }

      print(
          '${widget.runtimeType}, _accountBindInfoEntity:${_accountBindInfoEntity.toJson()}');
      if (mounted) {
        setState(() {
          loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      loadDataBloc.add(LoadFailEvent());

      LogUtil.toastException(e);
    }
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("[${widget.runtimeType}] accountType:$accountType");
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: BaseAppBar(
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              "res/drawable/account_bind_info.png",
              width: 16,
              height: 16,
            ),
            onPressed: () {
              _showInfoAlertView();
            },
          ),
        ],
        baseTitle: S.of(context).task_related_account,
      ),
      body: _pageView(),
    );
  }

  _pageView() {
    Widget child;

    switch (accountType) {
      case 0:
        child = _visitorWidget();

        break;

      case 1:
        child = _masterWidget();

        break;

      case 2:
        child = _childrenWidget();

        break;
    }

    return LoadDataContainer(
      hasFootView: false,
      bloc: loadDataBloc,
      onLoadData: getNetworkData,
      onRefresh: getNetworkData,
      enablePullUp: false,
      child: child,
    );
  }

  Widget _visitorWidget() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                color: HexColor('#F2F2F2'),
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ), //设置四周圆角 角度
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Text(
                      S.of(context).current_account,
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6,
                    ),
                    child: Text(
                      _userInfo?.email ?? _shortAddress ?? '',
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 32,
                    ),
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        ClickOvalButton(
                          S.of(context).set_as_main_account,
                          () async {
                            try {
                              var isOk = await _api.postMrSetMaster();
                              print(
                                  "[${widget.runtimeType}],设为主账户, isOk:$isOk");
                              if (isOk.code == 0) {
                                loadDataBloc.add(LoadingEvent());
                              } else {
                                Fluttertoast.showToast(
                                    msg: isOk?.msg ??
                                        S.of(context).unkown_error);
                              }
                            } catch (e) {
                              LogUtil.toastException(e);
                            }
                          },
                          width: 130,
                          height: 36,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ClickOvalButton(
                          S.of(context).set_as_sub_account,
                          () {
                            _showSetParisAlertView();
                          },
                          width: 130,
                          height: 36,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _masterWidget() {
    var subRelationships = _accountBindInfoEntity?.subRelationships ?? [];
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 5,
              ),
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).is_main_account,
                      style: _titleTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: HexColor('#F2F2F2'),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ), //设置四周圆角 角度
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              _userInfo?.email ?? _shortAddress ?? '',
                              style: _contentTextStyle,
                            ),
                            Spacer(),
                            IconButton(
                              icon: Image.asset(
                                "res/drawable/me_account_bind_setting.png",
                                width: 16,
                                height: 16,
                              ),
                              onPressed: () {
                                _showMoreAlertView();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 8,
                color: HexColor("#F2F2F2"),
              ),
              Container(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MeAccountBindRequestPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 16,
                      top: 15,
                      bottom: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          S.of(context).new_apply,
                          style: _contentTextStyle,
                        ),
                        Spacer(),
                        if ((_accountBindInfoEntity?.applyCount ?? 0) > 0)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: HexColor("#FF4C3B"),
                              borderRadius: BorderRadius.all(Radius.circular(
                                16.0,
                              )),
                            ),
                            child: Center(
                              child: Text(
                                '${_accountBindInfoEntity?.applyCount ?? 0}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: HexColor("#FFFFFF"),
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                          ),
                          child: Image.asset(
                            'res/drawable/me_account_bind_arrow.png',
                            width: 7,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 8,
                color: HexColor("#F2F2F2"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 16, bottom: 12),
                      child: RichText(
                        text: TextSpan(
                          text: S.of(context).current_related_child_account,
                          style: _titleTextStyle,
                          children: [
                            TextSpan(
                              text: S.of(context).related_children_count(
                                  "${subRelationships.length}"),
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          var isNotEmpty =
              (_accountBindInfoEntity?.subRelationships ?? []).isNotEmpty;

          SubRelationships model;
          if (isNotEmpty) {
            model = _accountBindInfoEntity.subRelationships[index];
          }
          var title = isNotEmpty ? model.email : _defaultEmptyText;
          int createAt = model?.bindTime ?? 0;

          return Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12,
                          bottom: subRelationships.length > 0 ? 0 : 12),
                      child: Text(
                        title,
                        style: _contentTextStyle,
                      ),
                    ),
                    if (createAt > 0)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          top: 6,
                        ),
                        child: Text(
                          Const.DATE_FORMAT.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  createAt * 1000)),
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                          textAlign: TextAlign.left,
                        ),
                      ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Spacer(),
                if (isNotEmpty)
                  FlatButton(
                    onPressed: () {
                      _postMrReset([model.userID], type: 2);
                    },
                    child: Text(
                      _cancelTitle,
                      style: _flatTextStyle,
                    ),
                  ),
              ],
            ),
          );
        },
                childCount:
                    subRelationships.isNotEmpty ? subRelationships.length : 1))
      ],
    );
  }

  Widget _childrenWidget() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).is_sub_account,
                      style: _titleTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: HexColor('#F2F2F2'),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ), //设置四周圆角 角度
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              _userInfo?.email ??
                                  _accountBindInfoEntity?.sub ??
                                  '',
                              style: _contentTextStyle,
                            ),
                            Spacer(),
                            IconButton(
                              icon: Image.asset(
                                "res/drawable/me_account_bind_setting.png",
                                width: 16,
                                height: 16,
                              ),
                              onPressed: () {
                                _showMoreAlertView();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 10,
                color: HexColor("#F2F2F2"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 16, bottom: 12),
                      child: RichText(
                        text: TextSpan(
                          text: S.of(context).binded_main_account,
                          style: _titleTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          var email = _accountBindInfoEntity?.request?.email;
          var state = _accountBindInfoEntity?.request?.state;
          var title =
              email ?? _accountBindInfoEntity?.master ?? _defaultEmptyText;

          var haveSubRow = _accountBindInfoEntity?.request != null;
          var subTitle = '';
          var status = '';
          HexColor hexColor;

          if ((_accountBindInfoEntity?.request == null) &&
              (_accountBindInfoEntity?.isSub ?? false)) {
            state = 1;
          }
          switch (state) {
            case 1:
              haveSubRow = false;

              status = '';
              break;

            case 0:
              haveSubRow = true;

              status = S.of(context).wait_for_main_account_to_bind;
              hexColor = HexColor('#999999');
              subTitle = S.of(context).cancel;
              break;

            case -1:
              haveSubRow = true;

              status = S.of(context).rejected;
              hexColor = HexColor('#FF4C3B');
              subTitle = S.of(context).reset;

              break;

            case -3:
              haveSubRow = true;

              status = S.of(context).wait_for_main_account_to_bind;
              hexColor = HexColor('#999999');
              subTitle = S.of(context).apply_cancelled;

              break;
          }

          int createAt = _accountBindInfoEntity?.request?.requestTime ?? 0;

          return Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 2,
              bottom: 16,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12,
                          bottom:
                              _accountBindInfoEntity?.request != null ? 0 : 12),
                      child: Text(
                        title,
                        style: _contentTextStyle,
                      ),
                    ),
                    Spacer(),
                    !haveSubRow
                        ? InkWell(
                            onTap: () {
                              _postMrReset([], type: 3);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                              ),
                              child: Text(
                                _cancelTitle,
                                style: _flatTextStyle,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: hexColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                  ],
                ),
                if (haveSubRow)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (createAt > 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 13,
                            ),
                            child: Text(
                              Const.DATE_FORMAT.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      createAt * 1000)),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        Spacer(),
                        InkWell(
                          onTap: state != -3
                              ? () async {
                                  print(subTitle);

                                  if (subTitle == S.of(context).cancel) {
                                    try {
                                      var isOk = await _api.postCancelRequest(
                                          id: _accountBindInfoEntity
                                                  ?.request?.id ??
                                              0);

                                      print(
                                          "[${widget.runtimeType}],1,打卡关联-取消关联, isOk:$isOk");

                                      if (isOk.code == 0) {
                                        loadDataBloc.add(LoadingEvent());
                                      } else if (isOk.code == -1003) {
                                        Fluttertoast.showToast(msg: S.of(context).no_opt_permisson);
                                      } else if (isOk.code == -1004) {
                                        Fluttertoast.showToast(
                                            msg: S.of(context).sub_account_apply_pending
                                        );
                                      } else if (isOk.code == -1007) {
                                        Fluttertoast.showToast(
                                            msg: S.of(context).reach_max_sub_account);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: isOk?.msg ?? S.of(context).unkown_error);
                                      }
                                    } catch (e) {
                                      LogUtil.toastException(e);
                                    }
                                  } else {
                                    _showSetParisAlertView();
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                            ),
                            child: Text(
                              subTitle,
                              style: TextStyle(
                                color: state != -3
                                    ? HexColor("#1F81FF")
                                    : hexColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ),
              ],
            ),
          );
        }, childCount: 1))
      ],
    );
  }

  Widget _cancelItem(BuildContext context) {
    return ClickOvalButton(
      S.of(context).cancel,
      () {
        Navigator.pop(context, false);
      },
      width: 115,
      height: 36,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontColor: DefaultColors.color999,
      btnColor: [Colors.transparent],
    );
  }

  double _moreOffsetLeft = 46;
  double _moreOffsetTop = 98.0 + 76.0;
  double _moreSizeWidth = 120;
  double _moreSizeHeight = 92.0;

  _showMoreAlertView() {
    var size = MediaQuery.of(context).size;
    _moreOffsetLeft = size.width - _moreSizeWidth - 16;
    //_moreOffsetTop = size.height * 0.3; // padding :32
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          left: _moreOffsetLeft,
          top: _moreOffsetTop,
          child: BubbleWidget(_moreSizeWidth, _moreSizeHeight, Colors.white,
              BubbleArrowDirection.top,
              length: 50,
              innerPadding: 0.0,
              child: Container(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (subContext, index) {
                    var title = "";

                    switch (accountType) {
                      case 0:
                        break;

                      case 1:
                        if (index == 2) {
                          title = "";
                        } else if (index == 0) {
                          title = S.of(context).unbind_all;
                        } else if (index == 1) {
                          title = S.of(context).set_as_sub_account;
                        }
                        break;

                      case 2:
                        if (index == 2) {
                          title = "";
                        } else if (index == 0) {
                          title = S.of(context).change_main_account;
                        } else if (index == 1) {
                          title = S.of(context).change_main_account;
                        }
                        break;
                    }

                    return SizedBox(
                      width: 100,
                      height: index == 0 ? 44 : 36,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          switch (accountType) {
                            case 0:
                              break;

                            case 1:
                              if (index == 0) {
                                _showUnbindAlertView();
                              } else if (index == 1) {
                                _showSetChildrenAlertView();
                              }
                              break;

                            case 2:
                              if (index == 0) {
                                _showSetParisAlertView();
                              } else if (index == 1) {
                                _showParisAlertView();
                              }
                              break;
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Divider(
                              height: 0.5,
                              color: DefaultColors.colorf2f2f2,
                              indent: 13,
                              endIndent: 13,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  8, index == 0 ? 12 : 8, 8, 8),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: DefaultColors.color333,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: 2,
                ),
              )),
        ),
      ),
    );
  }

  _showUnbindAlertView() {
    var subRelationships = (_accountBindInfoEntity?.subRelationships ?? []);

    // if (subRelationships.isEmpty) {
    //   Fluttertoast.showToast(msg: '已解除所有关联子账户');
    //   return;
    // }

    UiUtil.showAlertView(
      context,
      title: S.of(context).unbind_all,
      actions: [
        ClickOvalButton(
          S.of(context).unbind,
          () async {
            Navigator.pop(context, false);

            List<int> userIDs = [];
            if (subRelationships.isNotEmpty) {
              for (var item in subRelationships) {
                userIDs.add(item.userID);
              }
            }
            _postMrReset(userIDs);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).re_think,
          () {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).unbind_main_account_warning,
    );
  }

  _showSetChildrenAlertView() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).set_as_sub_account,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () async {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).continue_text,
          () async {
            Navigator.pop(context, false);

            _showSetParisAlertView();
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).change_main_account_warning,
    );
  }

  _showSetParisAlertView() {
    // todo:判断：你已经申请xx为主账户，是否再次设置。。。
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: HexColor('#FFF2F2F2'),
        width: 0.5,
      ),
    );

    _addressEditController.text = "";

    var _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
    var addressExample = 'hyn1ntjklkvx9jlkrz9';
    var addressHint = S.of(context).example + ': $addressExample...';
    var addressErrorHint = S.of(context).input_valid_hyn_address;

    UiUtil.showAlertView(
      context,
      title: S.of(context).related_setting_title,
      actions: [
        _cancelItem(context),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          () async {
            if (!_addressKey.currentState.validate()) {
              return;
            }

            var text = _addressEditController.text;
            if (text?.isNotEmpty ?? false) {
              try {
                var isOk = await _api.postMrRequest(address: text);
                print("[${widget.runtimeType}],设为子账户, isOk.code:${isOk.code}");

                if (isOk.code == 0) {
                  loadDataBloc.add(LoadingEvent());
                } else if (isOk.code == -1007) {
                  Fluttertoast.showToast(
                      msg: S.of(context).requested_main_reach_sub_account_max);
                } else if (isOk.code == -1004) {
                  loadDataBloc.add(LoadingEvent());
                  Fluttertoast.showToast(
                      msg: S.of(context).already_sub_account_or_pending);
                } else if (isOk.code == -1003) {
                  Fluttertoast.showToast(
                      msg: S
                          .of(context)
                          .apply_main_account_is_not_recommended_account);
                } else if (isOk.code == -20014) {
                  //Fluttertoast.showToast(msg: '申请关联的账号不是主账号');
                  _showCheckAlertView();
                } else {
                  Fluttertoast.showToast(
                      msg: isOk?.msg ?? S.of(context).unkown_error);
                }
              } catch (e) {
                LogUtil.toastException(e);
              }

              Navigator.pop(context, true);
            }
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      isInputValue: true,
      detail: S.of(context).input_main_account_address_or_qrcode,
      contentItem: Material(
        child: Form(
          key: _addressKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 22,
              right: 22,
              bottom: 8,
            ),
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  controller: _addressEditController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    var ethAddress = WalletUtil.bech32ToEthAddress(value);
                    if (ethAddress?.isEmpty ?? true) {
                      return S
                          .of(context)
                          .main_account_hyn_address_can_not_null;
                    } else if (!value.startsWith('hyn1')) {
                      return addressErrorHint;
                    } else if (!_basicAddressReg.hasMatch(ethAddress)) {
                      return addressErrorHint;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: HexColor('#FFF2F2F2'),
                    hintText: addressHint,
                    hintStyle: TextStyle(
                      color: HexColor('#FF999999'),
                      fontSize: 13,
                    ),
                    focusedBorder: border,
                    focusedErrorBorder: border,
                    enabledBorder: border,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () async {
                        UiUtil.showScanImagePickerSheet(context,
                            callback: (String text) async {
                          _addressEditController.text = await _parseText(text);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          ExtendsIconFont.qrcode_scan,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    //contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 13),
                  onSaved: (value) {
                    // print("[$runtimeType] onSaved, inputValue:$value");
                  },
                  onChanged: (String value) {
                    // print("[$runtimeType] onChanged, inputValue:$value");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _parseText(String scanStr) async {
    print("[扫描结果] scanStr:$scanStr");

    if (scanStr == null) {
      return '';
    } else if (scanStr.contains(PromoteQrCodePage.downloadDomain) ||
        scanStr.contains(RpFriendInvitePage.shareDomain)) {
      var fromArr = scanStr.split("from=");
      if (fromArr[1].length > 0) {
        fromArr = fromArr[1].split("&");
        if (fromArr[0].length > 0) {
          return fromArr[0];
        }
      }
    } else if (scanStr.startsWith('hyn1')) {
      return scanStr;
    }
    return '';
  }

  _showParisAlertView() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).set_as_main_account,
      actions: [
        _cancelItem(context),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).continue_text,
          () async {
            Navigator.pop(context, true);

            print('发送申请主账户请求');

            try {
              var isOk = await _api.postMrSetMaster();
              print("[${widget.runtimeType}],设为主账户, isOk:$isOk");

              if (isOk.code == 0) {
                loadDataBloc.add(LoadingEvent());
              } else if (isOk.code == -1003) {
                Fluttertoast.showToast(msg: S.of(context).no_opt_permisson);
              } else if (isOk.code == -1004) {
                Fluttertoast.showToast(
                    msg: S.of(context).already_sub_account_or_pending);
              } else if (isOk.code == -1007) {
                Fluttertoast.showToast(
                    msg: S.of(context).reach_max_sub_account);
              } else {
                Fluttertoast.showToast(
                    msg: isOk?.msg ?? S.of(context).unkown_error);
              }
            } catch (e) {
              LogUtil.toastException(e);
            }
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).apply_main_account_warning,
    );
  }

  _showInfoAlertView() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).ralated_info_title,
      actions: [
        ClickOvalButton(
          S.of(context).related_ok,
          () {
            Navigator.pop(context, true);
          },
          width: 200,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).ralated_info_content,
    );
  }

  _showCheckAlertView() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).related_setting_title,
      actions: [
        _cancelItem(context),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).reset,
          () {
            Navigator.pop(context, true);

            _showSetParisAlertView();
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).apply_main_account_warning,
    );
  }

  // type: 1: 所有子,2: 某个, 3:主
  _postMrReset(List<int> userIDs, {int type = 0}) async {
    try {
      var isOk = await _api.postMrReset(userIDs: userIDs);
      print(
          "[${widget.runtimeType}],解除所有关联:$type, userIDs:$userIDs, isOk:$isOk");

      if (isOk.code == 0) {
        loadDataBloc.add(LoadingEvent());
      } else if (isOk.code == -1003) {
        Fluttertoast.showToast(msg: S.of(context).no_opt_permisson);
      } else if (isOk.code == -1004) {
        Fluttertoast.showToast(msg: S.of(context).sub_account_apply_pending);
      } else if (isOk.code == -1007) {
        Fluttertoast.showToast(msg: S.of(context).reach_max_sub_account);
      } else {
        Fluttertoast.showToast(msg: isOk?.msg ?? S.of(context).unkown_error);
      }
    } catch (e) {
      LogUtil.toastException(e);
    }
  }
}

/*补充：
* 1.申请列表，倒序
* 2.过滤已经过期的申请
* 3.取消所有子账户
* */
