import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
import 'package:titan/src/components/app_lock/app_lock_component.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/pages/app_lock/app_lock_screen.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'app_lock_set_pwd_page.dart';
import 'app_lock_wallet_not_backup_dialog.dart';

class AppLockPreferencesPage extends StatefulWidget {
  AppLockPreferencesPage();

  @override
  State<StatefulWidget> createState() {
    return _AppLockPreferencesPageState();
  }
}

class _AppLockPreferencesPageState extends State<AppLockPreferencesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        backgroundColor: Colors.white,
        baseTitle: '应用锁',
      ),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: [
            _basicPreferences(),
            _bioAuthPreference(),
            _awayTimePreference(),
          ],
        ),
      ),
    );
  }

  _basicPreferences() {
    return _section(
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '应用锁',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                FlutterSwitch(
                  width: 54.0,
                  height: 26.0,
                  toggleSize: 18.0,
                  activeColor: HexColor('#EDC313'),
                  inactiveColor: HexColor('#DEDEDE'),
                  value: AppLockInheritedModel.of(context).isLockEnable,
                  onToggle: (value) {
                    _setUpAppLock(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 8.0),
      childPadding: EdgeInsets.symmetric(vertical: 0.0),
    );
  }

  _awayTimePreference() {
    var timeValueList = [0, 60, 300, 3600, 18000];
    var timeShowList = ['立即', '1分钟', '5分钟', '1小时', '5小时'];
    if (AppLockInheritedModel.of(context).isLockEnable) {
      return SliverToBoxAdapter(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '自动锁定时间',
                        style: TextStyle(
                          fontSize: 12,
                          color: DefaultColors.color999,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Column(
                    children: List.generate(timeValueList.length, (index) {
                      var timeShow = index == 0 ? '立即' : '如果离开${timeShowList[index]}';
                      var selected =
                          timeValueList[index] == AppLockInheritedModel.of(context).lockAwayTime;
                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                timeShow,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              if (selected)
                                Image.asset(
                                  'res/drawable/ic_check_selected.png',
                                  width: 18,
                                  height: 18,
                                ),
                            ],
                          ),
                        ),
                        onTap: () {
                          BlocProvider.of<AppLockBloc>(context).add(
                            SetWalletLockAwayTimeEvent(timeValueList[index]),
                          );
                        },
                      );
                    }),
                  ),
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '离开应用一定时间后应用锁将自动锁定应用，继续使用应用需要先解锁',
                    style: TextStyle(
                      color: DefaultColors.color999,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: SizedBox(),
      );
    }
  }

  _bioAuthPreference() {
    return FutureBuilder(
      future: BioAuthUtil.checkBioAuthAvailable(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          bool isBioAuthAvailable = snapshot.data;
          if (isBioAuthAvailable && AppLockInheritedModel.of(context).isLockEnable) {
            return _section(
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '快捷解锁',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    FlutterSwitch(
                      width: 54.0,
                      height: 26.0,
                      toggleSize: 18.0,
                      activeColor: HexColor('#EDC313'),
                      inactiveColor: HexColor('#DEDEDE'),
                      value: AppLockInheritedModel.of(context).isBioAuthEnabled,
                      onToggle: (value) {
                        _setUpBioAuth(value);
                      },
                    ),
                  ],
                ),
              ),
              title: '生物识别',
              childPadding: EdgeInsets.symmetric(vertical: 0.0),
            );
          }
        }
        return SliverToBoxAdapter(
          child: SizedBox(),
        );
      },
    );
  }

  _setUpAppLock(bool value) async {
    if (value) {
      var notBackUpWalletList = await WalletUtil.getNotBackUpWalletList();
      if (notBackUpWalletList.isNotEmpty) {
        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            enableDrag: false,
            builder: (BuildContext context) {
              return AppLockWalletNotBackUpDialog(notBackUpWalletList);
            });
      } else {
        _showSetPwdDialog(() {
          BlocProvider.of<AppLockBloc>(context).add(
            SetWalletLockEvent(value),
          );
        });
      }
    } else {
      _showWalletLockDialog(() {
        BlocProvider.of<AppLockBloc>(context).add(
          SetWalletLockEvent(value),
        );
      });
    }
  }

  _setUpBioAuth(bool value) async {
    if (value) {
      _showWalletLockDialog(() async {
        var authConfig = await BioAuthUtil.getAuthConfig(
          null,
          authType: AuthType.walletLock,
        );

        var result = await BioAuthUtil.auth(
          context,
          BioAuthUtil.currentBioMetricType(authConfig),
        );

        if (result) {
          authConfig.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;
          BioAuthUtil.saveAuthConfig(
            authConfig,
            null,
            authType: AuthType.walletLock,
          );

          BlocProvider.of<AppLockBloc>(context).add(
            SetWalletLockBioAuthEvent(value),
          );
          //await AppLockUtil.setBioAuth(value);

          UiUtil.showHintToast(
            context,
            Image.asset(
              'res/drawable/ic_toast_check.png',
              width: 60,
              height: 60,
            ),
            S.of(context).set_bio_auth_success,
          );
        } else {
          UiUtil.showHintToast(
              context,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'res/drawable/ic_toast_cross.png',
                  width: 30,
                  height: 30,
                ),
              ),
              S.of(context).set_bio_auth_fail);
        }
      });
    } else {
      _showWalletLockDialog(() {
        BlocProvider.of<AppLockBloc>(context).add(
          SetWalletLockBioAuthEvent(value),
        );
      });
    }
  }

  _showWalletLockDialog(Function onUnlock) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AppLockScreen(
            onUnlock: () {
              Navigator.of(context).pop();
              onUnlock.call();
            },
            isDialog: true,
          );
        });
  }

  _showSetPwdDialog(Function onPwdSet) {
    var height = MediaQuery.of(context).size.height - 80;
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AppLockSetPwdPage(
                onPwdSet: onPwdSet,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _section(
    Widget child, {
    String title = '',
    EdgeInsetsGeometry childPadding = const EdgeInsets.all(16.0),
    EdgeInsetsGeometry padding = const EdgeInsets.all(0.0),
  }) {
    return SliverToBoxAdapter(
      child: Container(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              title.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 12,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: childPadding,
                  child: child,
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }
}
