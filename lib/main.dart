import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/data/db/heco_txn_dao.dart';
import 'package:titan/src/data/db/transfer_history_dao.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
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
    BuildEnvironment.init(
        channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV, packageType: "test");
  }

  WidgetsFlutterBinding.ensureInitialized();
  TitanPlugin.initFlutterMethodCall();

  //init key for security share
//  TitanPlugin.initKeyPair();

  //init injector
  Api api = Api();
  SearchHistoryDao searchDao = SearchHistoryDao();
  TransferHistoryDao transferHistoryDao = TransferHistoryDao();
  TxnInfoDao hecoTxnDao = TxnInfoDao();
  Repository repository = Repository(
    api: api,
    searchHistoryDao: searchDao,
    transferHistoryDao: transferHistoryDao,
    txnInfoDao: hecoTxnDao,
  );
  SearchInteractor searchInteractor = SearchInteractor(repository);
  TransactionInteractor transactionInteractor = TransactionInteractor(repository);

  BlocSupervisor.delegate = AppBlocDelegate();

  runApp(Injector(
    child: App(),
    repository: repository,
    searchInteractor: searchInteractor,
    transactionInteractor: transactionInteractor,
  ));

}
