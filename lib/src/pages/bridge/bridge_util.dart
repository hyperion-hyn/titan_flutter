import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

class BridgeUtil {
  static String getCrossChainStatusText(int status) {
    if (status == null) {
      return '';
    }

    if (status == 0) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_submitted;
    } else if (status == 1) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 2) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 3) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 4) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 5) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 6) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_processing;
    } else if (status == 7) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_success;
    } else if (status == 8) {
      return S.of(Keys.rootKey.currentContext).bridge_record_status_failed;
    }else {
      return '';
    }
  }
}

enum CrossChainRecordStatus {
  CROSS_CHAIN_APPLY,
  ATLAS_PROCESSING_HECO_WAIT,
  ATLAS_FINISH_HECO_WAIT,
  ATLAS_FINISH_HECO_PROCESSING,
  HECO_PROCESSING_ATLAS_WAIT,
  HECO_FINISH_ATLAS_WAIT,
  HECO_FINISH_ATLAS_PROCESSING,
  CROSS_CHAIN_FINISH,
}
