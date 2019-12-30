import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';
import 'package:titan/src/pages/setting_on_launcher/setting_on_launcher_page.dart';

class RootPageControlComponent extends StatefulWidget {
  RootPageControlComponent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RootPageControlComponentState();
  }
}

class RootPageControlComponentState extends State<RootPageControlComponent> {
  @override
  void initState() {
    super.initState();
    launchRootPage();
  }

  void launchRootPage() async {
    var prefs = await SharedPreferences.getInstance();
    bool notFirstTimeLauncher = prefs.containsKey(PrefsKey.FIRST_TIME_LAUNCHER_KEY);
    if (notFirstTimeLauncher) {
//    if (false) {
      //launch dashboard
      BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(page: AppTabBarPage()));
    } else {
      //launch setting
      BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(page: SettingOnLauncherPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootPageControlBloc, RootPageControlState>(
      builder: (ctx, state) {
        if (state is UpdateRootPageState) {
          return state.child;
        }
        return Scaffold();
      },
    );
  }
}
