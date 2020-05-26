
import 'package:flutter_test/flutter_test.dart';
import 'package:titan/env.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/data/db/transfer_history_dao.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  test('transaction test', () async {
    TransferHistoryDao transferHistoryDao = TransferHistoryDao();
//    TransactionDetailVo transactionDetailVo1 = TransactionDetailVo();
//    transactionDetailVo1.hash = "111111";
//    transactionDetailVo1.fromAddress = "111111";
//    transferHistoryDao.insertOrUpdate(transactionDetailVo1);
//    TransactionDetailVo transactionDetailVo2 = TransactionDetailVo();
//    transactionDetailVo2.id = 30;
//    transactionDetailVo2.hash = "222222";
//    transactionDetailVo2.fromAddress = "111111";
//    transferHistoryDao.insertOrUpdate(transactionDetailVo2);
//
//    TransactionDetailVo transactionDetailVo3 = TransactionDetailVo();
//    transactionDetailVo3.id = 30;
//    transactionDetailVo3.hash = "333333";
//    transactionDetailVo3.fromAddress = "111111";
//    transferHistoryDao.insertOrUpdate(transactionDetailVo3);
    List<TransactionDetailVo> transactionList = await transferHistoryDao.getList(LocalTransferType.LOCAL_TRANSFER_ETH, "111111");
    expect(2, transactionList.length);
    expect("111111", transactionList[0].hash);
    expect("333333", transactionList[1].hash);
    expect(30, transactionList[1].id);
  });
}
