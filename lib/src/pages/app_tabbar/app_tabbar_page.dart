import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/scaffold_map.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/updater/updater_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/app_tabbar/bottom_fabs_widget.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_tabs_page.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_tabs_page_deprecated.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/discover/discover_page.dart';
import 'package:titan/src/pages/discover/dmap_define.dart';
import 'package:titan/src/pages/home/bloc/bloc.dart';
import 'package:titan/src/pages/market/PartnerExchangeLoginPage.dart';
import 'package:titan/src/pages/news/info_detail_page.dart';
import 'package:titan/src/pages/news/infomation_page.dart';
import 'package:titan/src/pages/wallet/wallet_tabs_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../../widget/draggable_scrollable_sheet.dart' as myWidget;

import '../../../env.dart';
import '../home/home_page.dart';
import '../market/exchange/exchange_page.dart';
import '../wallet/wallet_tabs_page.dart';
import '../mine/my_page.dart';
import 'announcement_dialog.dart';
import 'bloc/app_tabbar_bloc.dart';
import 'bloc/app_tabbar_event.dart';
import 'bloc/app_tabbar_state.dart';
import 'drawer_component.dart';
import 'package:titan/src/pages/red_pocket/rp_invite_friend_page.dart';

class AppTabBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppTabBarPageState();
  }
}

class AppTabBarPageState extends BaseState<AppTabBarPage> with TickerProviderStateMixin {
  final GlobalKey _bottomBarKey = GlobalKey(debugLabel: 'bottomBarKey');
  final GlobalKey _discoverKey = GlobalKey(debugLabel: '__discover_key__');

  var _fabsHeight = 56;

  int _currentTabIndex = 0;

  AnimationController _bottomBarPositionAnimationController;
  AnimationController _fabsBarPositionAnimationController;
  DateTime _lastPressedAt;
  StreamSubscription _clearBadgeSubcription;

  ScaffoldMapState _mapState;
  var _isShowAnnounceDialog = false;
  var homePageFirst = true;

  @override
  void initState() {
    super.initState();

//    TitanPlugin.getClipboardData();
    getClipboardData();

    BlocProvider.of<SettingBloc>(context).listen((state) {
      if (state is UpdatedSettingState) {
        Future.delayed(Duration(milliseconds: 2000)).then((value) {
          MemoryCache.setContractErrorStr();
        });
      }
    });

    _bottomBarPositionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );

    _fabsBarPositionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );

    //set the status bar color
//    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent(updateGasPrice: true));
    });

//    Future.delayed(Duration(milliseconds: 2000)).then((value) {
//      BlocProvider.of<WalletCmpBloc>(context).add(UpdateGasPriceEvent());
//    });

    // 检测是否有新弹窗
    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      //print('[home] --> check new announcement');
      BlocProvider.of<AppTabBarBloc>(context).add(CheckNewAnnouncementEvent());
    });

    _clearBadgeSubcription = Application.eventBus.on().listen((event) {
      //print('[home] --> clear badge');
      if (event is ClearBadgeEvent) {
        BlocProvider.of<AppTabBarBloc>(context).add(InitialAppTabBarEvent());
      }
    });

    TitanPlugin.msgPushChangeCallBack = (Map values) {
      _pushWebView(values);
    };

    TitanPlugin.urlLauncherCallBack = (Map values) {
      _urlLauncherAction(values);
    };

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AppTabBarPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void onCreated() {
    TitanPlugin.f2pDeeplink();
    super.onCreated();
  }

  void getClipboardData() async {
    var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text.contains("titan://map3/detail")) {
      var shareUser = clipboardData.text.split("key=")[1];
      MemoryCache.shareKey = shareUser;
    }
  }

  void _pushWebView(Map values) {
    var url = values["out_link"];
    var title = values["title"];
    var content = values["content"];
    print("[dd] content:${content}");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InfoDetailPage(
                  id: 0,
                  url: url,
                  title: title,
                  content: content,
                )));
  }

  Future<void> _urlLauncherAction(Map values) async {
    var type = values["type"];
    var subType = values["subType"];
    var content = values["content"];
    print('[Home_page] _urlLauncherAction, values:${values}');
    if (type == "map3" && subType == "detail") {
      var nodeId = content["map3"];
      var key = content["key"];
      MemoryCache.shareKey = key;
      print("shareuser jump $key");
      var infoEntity = Map3InfoEntity.onlyNodeId(nodeId);
      Application.router.navigateTo(context,
          Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(infoEntity.toJson())}');
    } else if (type == "rp" && subType == "detail") {
      var inviterAddress = content["from"];
      var walletName = content["name"];
      showInviteDialog(context,inviterAddress,walletName);
    } else if (type == "location" && subType == 'share') {
      ///When received encrypted msg, show dialog
      ///
      UiUtil.showDecryptDialog(context, () async {
        var encryptedMsg = content['msg'];
        var fileName;
        var password;
        if (encryptedMsg.startsWith(Const.CIPHER_TEXT_PREFIX)) {
          var _activeWallet = WalletInheritedModel.of(context).activatedWallet;
          if (_activeWallet == null) {
            Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
            return;
          }
          fileName = _activeWallet.wallet.keystore.fileName;
          password = await UiUtil.showWalletPasswordDialogV2(context, _activeWallet.wallet,
              dialogTitle: S.of(context).wallet_password_decrypt);
        }
        if ((password != null && encryptedMsg.startsWith(Const.CIPHER_TEXT_PREFIX)) ||
            !encryptedMsg.startsWith(Const.CIPHER_TEXT_PREFIX)) {
          Navigator.pop(context);
          (Keys.scaffoldMap.currentState as ScaffoldCmpMapState)?.back();
          Routes.popUntilCachedEntryRouteName(context);
        }

        var poi = await ciphertextToPoi(Injector.of(context).repository, encryptedMsg,
            fileName: fileName, password: password);

        ///switch to map page first, then poi can show correctly.
        BlocProvider.of<AppTabBarBloc>(context).add(ChangeTabBarItemEvent(index: 0));
        await Future.delayed(Duration(milliseconds: 300));
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
      });
    }
  }

  @override
  void dispose() {
    _clearBadgeSubcription.cancel();
    super.dispose();
  }

  CreateDAppWidgetFunction createDAppWidgetFunction;

  @override
  Widget build(BuildContext context) {
    bool isDebug = env.buildType == BuildType.DEV;
    return UpdaterComponent(
      child: MultiBlocListener(
        listeners: [
          BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
            listener: (context, state) {
              _mapState = state;
              if (state is DefaultScaffoldMapState) {
                _bottomBarPositionAnimationController.animateBack(0, curve: Curves.easeInQuart);
              } else {
                _bottomBarPositionAnimationController.animateTo(1, curve: Curves.easeOutQuint);
              }
            },
          ),
          BlocListener<AppTabBarBloc, AppTabBarState>(
            listener: (context, state) {
              if (state is ChangeTabBarItemState) {
                this.setState(() {
                  this._currentTabIndex = state.index;
                });
              }
            },
          ),
          BlocListener<DiscoverBloc, DiscoverState>(
            listener: (context, state) {
              if (state is ActiveDMapState) {
                DMapCreationModel model = DMapDefine.kMapList[state.name];
                print("[app_Dmap] ---1");

                if (model != null) {
                  this.setState(() {
                    print("[app_Dmap] ---2 - 2");
                    createDAppWidgetFunction = model.createDAppWidgetFunction;
                  });
                }
              } else {
                this.setState(() {
                  print("[app_Dmap] ---2 - 3");
                  createDAppWidgetFunction = null;
                });
              }
            },
          ),
        ],
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
//          drawer: isDebug ? DrawerComponent() : null,
          body: NotificationListener<myWidget.DraggableScrollableNotification>(
            onNotification: (notification) {
              bool isHomePanelMoving = notification.context.widget.key == Keys.homePanelKey;
              if (notification.extent <= notification.anchorExtent &&
                  ((_isDefaultState && isHomePanelMoving) || (!_isDefaultState && !isHomePanelMoving))) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  var toValue = (notification.extent * (notification.maxHeight + _fabsHeight)) / notification.maxHeight;
                  _fabsBarPositionAnimationController.value = toValue;
                });
              }

              var shouldShow = notification.extent <= notification.anchorExtent;
              SchedulerBinding.instance.addPostFrameCallback((_) {
                (_bottomBarKey.currentState as BottomFabsWidgetState).setVisible(shouldShow);
              });

              return true;
            },
            child: WillPopScope(
              onWillPop: () async {
                var isHandled = (Keys.scaffoldMap.currentState as ScaffoldCmpMapState)?.back();
                if (isHandled == true) {
                  return false;
                }

                isHandled = (_discoverKey.currentState as DiscoverPageState)?.back();
                if (isHandled == true) {
                  return false;
                }

                if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
                  _lastPressedAt = DateTime.now();
                  Fluttertoast.showToast(msg: S.of(context).click_again_to_exist_app);
                  return false;
                }
                return true;
              },
              child: BlocBuilder<AppTabBarBloc, AppTabBarState>(
                  builder: (context, state) {
                if (state is CheckNewAnnouncementState &&
                    state.announcement != null) {
                  //todo maprich _isShowAnnounceDialog 为 true
                  _isShowAnnounceDialog = false;
                  Application.isUpdateAnnounce = true;
                }

                return SafeArea(child: PartnerExchangeLoginPage());
              }),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isDefaultState {
    return _mapState is DefaultScaffoldMapState || _mapState == null;
  }

  Widget userLocationBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        var additionalBottomPadding = MediaQuery.of(context).padding.bottom;
        var barHeight = additionalBottomPadding + kBottomNavigationBarHeight;

        var bottomMostRelative = RelativeRect.fromLTRB(
            0.0, constraints.biggest.height - _fabsHeight - (_isDefaultState ? barHeight : 0), 0.0, 0.0);
        var topMostRelative = RelativeRect.fromLTRB(0.0, 0, 0.0, 0);
        final Animation<RelativeRect> barAnimationRect = _fabsBarPositionAnimationController.drive(
          RelativeRectTween(
            begin: bottomMostRelative,
            end: topMostRelative,
          ),
        );

        return Stack(
          children: <Widget>[
            PositionedTransition(
                rect: barAnimationRect,
                child: BottomFabsWidget(
                  key: _bottomBarKey,
                  showBurnBtn: true,
                )),
          ],
        );
      },
    );
  }

  Widget bottomNavigationBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        var additionalBottomPadding = MediaQuery.of(context).padding.bottom;
        var barHeight = additionalBottomPadding + kBottomNavigationBarHeight;
        var expandedRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height - barHeight, 0.0, 0.0);
        var hideRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height, 0.0, -barHeight);
        final Animation<RelativeRect> barAnimationRect = _bottomBarPositionAnimationController.drive(
          RelativeRectTween(
            begin: expandedRelative,
            end: hideRelative,
          ),
        );

        return Stack(
          children: <Widget>[
            PositionedTransition(
              rect: barAnimationRect,
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    tabItem(Icons.home, S.of(context).home_page, 0),
                    tabItem(Icons.account_balance_wallet, S.of(context).wallet, 1),
                    tabItem(Icons.explore, S.of(context).node, 2),
                    tabItem(Icons.description, S.of(context).information, 3),
                    tabItem(Icons.person, S.of(context).my_page, 4),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget tabItem(IconData iconData, String text, int index) {
    bool selected = index == this._currentTabIndex;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(80),
          onTap: () => {
            this.setState(() {
              this._currentTabIndex = index;
            })
          },
          child: Container(
            padding: EdgeInsets.only(top: 4, bottom: 2),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      iconData,
                      color: selected ? Theme.of(context).primaryColor : Colors.black38,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 12, color: selected ? Theme.of(context).primaryColor : Colors.black38),
                    ),
                  ],
                ),
                if (Application.isUpdateAnnounce && index == 3)
                  Positioned(
                    top: 2,
                    right: 12,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: HexColor("#DA3B2A"),
                            shape: BoxShape.circle,
                            border: Border.all(color: HexColor("#DA3B2A"))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTabView(int index) {
    switch (index) {
      case 1:
        return WalletTabsPage();

      case 2:
        return AtlasNodeTabsPage();

      case 3:
        return InformationPage();

      case 4:
        return MyPage();
    }

    if (createDAppWidgetFunction != null) {
      return createDAppWidgetFunction(context);
    } else {
      return BlocProvider(
          create: (ctx) => HomeBloc(ctx),
          child: HomePage(homePageFirst, () {
            homePageFirst = false;
          }, key: Keys.homePageKey));
    }
  }
}
