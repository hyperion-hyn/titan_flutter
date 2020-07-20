

//const EXCHANGE_DOMAIN = 'http://127.0.0.1';
//const WS_DOMAIN = 'ws://127.0.0.1:8081';
//const WS_DOMAIN = 'ws://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com:8081';
const EXCHANGE_DOMAIN = 'http://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com';

//账户相关：
const PATH_LOGIN_REGISTER = '/api/user/walletSignLogin'; // 注册登陆
const PATH_RECENT_ACTIVITY = '/api/user/getRecentActivity'; //最近活动


//k-line相关：
const PATH_HISTORY_TRADE = '/api/v1-b/market/trade_history'; // 所有用户历史交易数据
const PATH_HISTORY_DEPTH = '/api/v1-b/market/depth_history'; // 所有用户历史深度数据
const PATH_HISTORY_KLINE = '/api/v1-b/market/kline_history'; // 所有用户历史k线数据

//交易系统：
const PATH_ORDER_LIMIT = '/api/exchange/orderPutLimit'; // 下限价单
const PATH_ORDER_MARKET = '/api/exchange/orderPutMarket'; // 下市价单
const PATH_ORDER_CANCEL = '/api/exchange/orderCancel'; // 取消订单A
const PATH_ORDER_LIST = '/api/order/lists'; // 当前/历史 委托列表
const PATH_ORDER_LOG_LIST = '/api/order/dealDetailLists'; // 成交明细
const PATH_MARKET_INFO = '/api/exchange/getMarketInfo'; // 市场信息，如市价，费率，精度
const PATH_TYPE_CURR = '/api/quotation/getType2Currency'; // 币种兑换法币汇率

//资金操作
const PATH_ACCOUNT_ASSETS = '/api/account/assetsList'; // 资产列表
const PATH_TO_EXCHANGE = '/api/account/toExchange'; // 资金账户划转到交易账户
const PATH_TO_ACCOUNT = '/api/exchange/toAccount'; // 交易账户划转到资金账户
const PATH_GET_ADDRESS = '/api/account/getAddress'; // 获取充币地址
const PATH_WITHDRAW = '/api/account/withdraw'; // 申请提币
const PATH_WITHDRAW_CANCEL = '/api/account/cancelWithdraw'; // 取消提币
const PATH_ASSETS_HISTORY = '/api/account/getHistory'; // 充提记录
const PATH_QUICK_RECHARGE = '/api/account/recharge'; // 快速充币，只用于测试。
