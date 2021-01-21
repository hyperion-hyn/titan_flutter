import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
import 'package:titan/src/components/app_lock/app_lock_component.dart';
import 'package:titan/src/style/titan_sytle.dart';

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
        baseTitle: '钱包安全锁',
      ),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: [
            _basicPreferences(),
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
                      '安全锁',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlutterSwitch(
                    width: 54.0,
                    height: 26.0,
                    toggleSize: 18.0,
                    activeColor: HexColor('#EDC313'),
                    inactiveColor: HexColor('#DEDEDE'),
                    value: AppLockInheritedModel.of(context).isWalletLockEnable,
                    onToggle: (value) {
                      BlocProvider.of<AppLockBloc>(context).add(
                        SetWalletLockEvent(value),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '快捷解锁/生物验证',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlutterSwitch(
                    width: 54.0,
                    height: 26.0,
                    toggleSize: 18.0,
                    activeColor: HexColor('#EDC313'),
                    inactiveColor: HexColor('#DEDEDE'),
                    value: AppLockInheritedModel.of(context).isWalletLockBioAuthEnabled,
                    onToggle: (value) {
                      BlocProvider.of<AppLockBloc>(context).add(
                        SetWalletLockBioAuthEvent(value),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        childPadding: EdgeInsets.symmetric(vertical: 0.0));
  }

  _awayTimePreference() {
    var timeValueList = [0, 60, 300, 3600, 18000];
    var timeShowList = ['立即', '1分钟', '5分钟', '1小时', '5小时'];

    return _section(
      Column(
        children: List.generate(timeValueList.length, (index) {
          var timeShow = index == 0 ? '立即' : '如果离开${timeShowList[index]}';
          var selected =
              timeValueList[index] == AppLockInheritedModel.of(context).walletLockAwayTime;
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
      title: '自动锁定时间',
      childPadding: EdgeInsets.all(0),
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
