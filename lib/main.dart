import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/config.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/db/transfer_history_dao.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/global.dart';

import 'env.dart';
import 'src/basic/bloc/app_bloc_delegate.dart';
import 'src/data/api/api.dart';
import 'src/data/db/search_history_dao.dart';
import 'src/data/repository/repository.dart';
import 'src/domain/domain.dart';
import 'src/components/inject/injector.dart';
import 'src/plugins/titan_plugin.dart';

void main() {
  if (env == null) {
    BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
  }

  WidgetsFlutterBinding.ensureInitialized();
  TitanPlugin.initFlutterMethodCall();
  //init key for security share
//  TitanPlugin.initKeyPair();

  //init injector
  Api api = Api();
  SearchHistoryDao searchDao = SearchHistoryDao();
  TransferHistoryDao transferHistoryDao = TransferHistoryDao();
  Repository repository = Repository(api: api, searchHistoryDao: searchDao, transferHistoryDao: transferHistoryDao);
  SearchInteractor searchInteractor = SearchInteractor(repository);
  TransactionInteractor transactionInteractor = TransactionInteractor(repository);

  BlocSupervisor.delegate = AppBlocDelegate();

//  if (env.buildType == BuildType.PROD) {
  FlutterBugly.init(
    androidAppId: Config.BUGLY_ANDROID_APPID,
    iOSAppId: Config.BUGLY_IOS_APPID,
  );
//  }

  FlutterBugly.postCatchedException(
      () => runApp(RestartWidget(
            child: Injector(
              child: Container(
                key: Keys.componentKey,
                child: App(),
              ),
              repository: repository,
              searchInteractor: searchInteractor,
              transactionInteractor: transactionInteractor,
//      mapStore: ScaffoldMapStore(),
            ),
          )),
      debugUpload: env.buildType == BuildType.PROD, handler: (FlutterErrorDetails detail) {
    print(detail.toString());
    logger.e(detail.exception?.message, detail.exception, detail.stack);
  });
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => new _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
}
