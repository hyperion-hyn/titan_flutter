
class SocketUtil {

  //static final String domain = "ws://127.0.0.1:8081";
  static final String domain = "ws://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com:8081";

  static final String sub = "sub";
  static final String unSub = "unsub";

  // 所有交易对实时24小时统计数据
  static final String channelKLine24Hour = "ws.market.allsymbol.kline.24hour";

  // 指定交易对实时K线数据
  /*参数说明：
  * symbol: ethusdt
  * period: 1min,5min,15min,30min,60min,1day,1week,1mon,24hour
  * 注:24hour非标准固定起始点K线,其起始点步进周期为1min,数据计算周期24小时
  * */
  static String channelKLinePeriod(String symbol, String period) {
    return "ws.market.$symbol.kline.$period";
  }

  // 指定交易对实时深度数据
  /*参数说明：
  * symbol: ethusdt
  * level: -1
  * 注：-1表示不合并，其他表示对应精度
  * */
  static String channelExchangeDepth(String symbol, int level) {
    return "ws.market.$symbol.depth.$level";
  }

  // 指定交易对实时成交数据
  /*参数说明：
  * symbol: ethusdt
  * */
  static String channelTradeDetail(String symbol) {
    return "ws.market.$symbol.trade.detail";
  }

  // 指定交易对指定用户的实时委托数据
  /*参数说明：
  * uid: 1000
  * symbol: btcusdt
  * 注：订阅自身在btcusdt交易对上的实时委托数据
  * */
  static String channelUserTick(String uid, String symbol) {
    return "user.$uid.tick.$symbol";
  }
}