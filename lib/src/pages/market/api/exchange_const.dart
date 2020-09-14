class ExchangeConst {
//  static const EXCHANGE_DOMAIN =
//      "http://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com";
//  static const WS_DOMAIN =
//      "ws://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com:8081";

  static const EXCHANGE_DOMAIN = "https://exchange.hyn.space";
  static const WS_DOMAIN = "wss://ws-exchange.hyn.space";

  static const PATH_GET_ACCESS_SEED = '/api/user/getAccessSeed';

  ///账户相关：
  static const PATH_LOGIN_REGISTER = "/api/user/walletSignLogin"; // 注册登陆
  static const PATH_RECENT_ACTIVITY = "/api/user/getRecentActivity"; //最近活动

  ///k-line相关：
  static const PATH_HISTORY_TRADE =
      "/api/v1-b/market/trade_history"; // 所有用户历史交易数据
  static const PATH_HISTORY_DEPTH =
      "/api/v1-b/market/depth_history"; // 所有用户历史深度数据
  static const PATH_HISTORY_KLINE =
      "/api/v1-b/market/kline_history"; // 所有用户历史k线数据

  ///Banner
  static const PATH_BANNER_LIST = '/api/message/listBanner';

  ///交易系统：
//  static const PATH_ORDER_LIMIT = "/api/exchange/orderPutLimit"; // 下限价单
  static const PATH_ORDER_MARKET = "/api/exchange/orderPutMarket"; // 下市价单
//  static const PATH_ORDER_CANCEL = "/api/exchange/orderCancel"; // 取消订单A
//  static const PATH_ORDER_LIST = "/api/order/lists"; // 当前/历史 委托列表
  static const PATH_ORDER_LOG_LIST = "/api/order/dealDetailLists"; // 成交明细
  static const PATH_MARKET_ALL = '/api/v1-b/market/all';
  static const PATH_MARKET_INFO =
      "/api/exchange/getMarketInfo"; // 市场信息，如市价，费率，精度
  static const PATH_USD_CNY = "/api/quotation/getUSDCNY"; // 美元兑换人民币汇率
  static const PATH_TYPE_TO_CURRENCY = "/api/quotation/getType2Currency";

  ///资金操作
//  static const PATH_ACCOUNT_ASSETS = "/api/account/assetsList"; // 资产列表
  static const PATH_TO_EXCHANGE = "/api/account/toExchange"; // 资金账户划转到交易账户
  static const PATH_TO_ACCOUNT = "/api/exchange/toAccount"; // 交易账户划转到资金账户
  static const PATH_GET_ADDRESS = "/api/account/getAddress"; // 获取充币地址
  static const PATH_WITHDRAW = "/api/account/withdraw"; // 申请提币
  static const PATH_WITHDRAW_CANCEL = "/api/account/cancelWithdraw"; // 取消提币
  static const PATH_ASSETS_HISTORY = "/api/account/getHistory"; // 充提记录
  static const PATH_QUICK_RECHARGE = "/api/account/recharge"; // 快速充币，只用于测试。

  //user api
  static const PATH_ACCOUNT_ASSETS = "/api/v1/assetsList"; // 通过api请求资产列表
  static const PATH_ORDER_LIMIT = '/api/v1/orderPut'; //通过api下单
  static const PATH_ORDER_LIST = '/api/v1/orderList'; //通过api查看订单列表
  static const PATH_ORDER_CANCEL = "/api/v1/orderCancel"; // 取消订单
  static const PATH_GET_UID = '/api/v1/uid';  //获取uid

}
