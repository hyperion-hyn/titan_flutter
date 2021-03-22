class BridgeUtil {
  static String getCrossChainStatusText(int status) {
    if (status == null) {
      return '';
    }

    if (status == 0) {
      return '已提交';
    } else if (status == 1) {
      return '处理中';
    } else if (status == 2) {
      return '处理中';
    } else if (status == 3) {
      return '处理中';
    } else if (status == 4) {
      return '处理中';
    } else if (status == 5) {
      return '处理中';
    } else if (status == 6) {
      return '处理中';
    } else if (status == 7) {
      return '已完成';
    } else if (status == 8) {
      return '已失败';
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
