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
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
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
        baseTitle: S.of(context).app_lock,
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
                    S.of(context).app_lock,
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
    var timeShowList = [
      S.of(context).immediate,
      S.of(context).one_minute,
      S.of(context).five_minutes,
      S.of(context).one_hour,
      S.of(context).five_hours
    ];
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
                        S.of(context).auto_lock_time,
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
                      var timeShow =
                          index == 0 ? S.of(context).immediate : '${S.of(context).if_away}${timeShowList[index]}';
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
                    S.of(context).app_away_hint,
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
                        S.of(context).quick_unlock,
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
              title: S.of(context).bio_auth,
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
        UiUtil.showBottomDialogView(
          context,
          dialogHeight: MediaQuery.of(context).size.height - 90,
          isScrollControlled: true,
          showCloseBtn: false,
          customWidget: AppLockWalletNotBackUpDialog(notBackUpWalletList),
        );
      } else {
        _showSetPwdDialog(() {
          BlocProvider.of<AppLockBloc>(context).add(
            SetWalletLockEvent(value),
          );
        });
      }
    } else {
      BlocProvider.of<AppLockBloc>(context).add(
        SetWalletLockEvent(value),
      );
    }
  }

  _setUpBioAuth(bool value) async {
    if (value) {
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

        UiUtil.showStateHint(context, true, S.of(context).set_bio_auth_success);
      } else {
        UiUtil.showStateHint(context, false, S.of(context).set_bio_auth_fail);
      }
    } else {
      BlocProvider.of<AppLockBloc>(context).add(
        SetWalletLockBioAuthEvent(value),
      );
    }
  }

  _showSetPwdDialog(Function onPwdSet) {
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 90,
      isScrollControlled: true,
      customWidget: AppLockSetPwdPage(
        onPwdSet: onPwdSet,
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
