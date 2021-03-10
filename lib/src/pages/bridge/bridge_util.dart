class BridgeUtil {
  static String getCrossChainStatusText(int status) {
    String stateDesc = '';

    if (status == null) {
      return stateDesc;
    }

    switch (status) {
      case 0:
        stateDesc = '';
        break;
      case 1:
        stateDesc = '';
        break;
      case 2:
        stateDesc = '';
        break;
      case 3:
        stateDesc = '';
        break;
      case 4:
        stateDesc = '';
        break;
      case 5:
        stateDesc = '';
        break;
      case 6:
        stateDesc = '';
        break;
      case 7:
        stateDesc = '';
        break;
      default:
        stateDesc = '';
        break;
    }
    return stateDesc;
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
