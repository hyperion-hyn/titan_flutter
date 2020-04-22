import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/domain/model/photo_poi_list_model.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/components/account/bloc/bloc.dart';

import '../model/checkin_history.dart';
import '../api/map_rich_api.dart';
import '../model/bill_info.dart';
import '../model/common_response.dart';
import '../model/contract_info.dart';
import '../model/contract_info_v2.dart';
import '../model/daily_bills_type.dart';
import '../model/experience_info_v2.dart';
import '../model/fund_token.dart';
import '../model/mortgage_info.dart';
import '../model/mortgage_info_v2.dart';
import '../model/node_mortgage_info.dart';
import '../model/page_response.dart';
import '../model/pay_order.dart';
import '../model/power_detail.dart';
import '../model/promotion_info.dart';
import '../model/recharge_order_info.dart';
import '../model/quotes.dart';
import '../model/user_eth_address.dart';
import '../model/user_info.dart';
import '../model/user_level_info.dart';
import '../model/user_token.dart';
import '../model/withdrawal_info.dart';
import '../model/withdrawal_info_log.dart';

class UserService {
  static MapRichApi _mapRichApi = MapRichApi();

  static syncUserInfo([BuildContext context]) async {
    try {
      if (context == null) {
        context = _getRootContext();
      }
      var userService = UserService();
      var userToken = getUserToken(context);
      var userInfo = await userService.getUserInfo(userToken);
      BlocProvider.of<AccountBloc>(context).add(UpdateUserEvent(userInfo: userInfo));
    } catch (e) {
      logger.e(e);
    }
  }

  static syncCheckInData([BuildContext context]) async {
    try {
      if (context == null) {
        context = _getRootContext();
      }
      var userService = UserService();
      var checkInModel = await userService.checkInCountV2();
      BlocProvider.of<AccountBloc>(context).add(UpdateCheckInEvent(checkInModel: checkInModel));
    } catch (e) {
      logger.e(e);
    }
  }

  static BuildContext _getRootContext() {
    return Keys.rootKey.currentContext;
  }

  static UserToken getUserToken([BuildContext context]) {
    if (context == null) {
      context = _getRootContext();
    }
    UserToken userToken = AccountInheritedModel.of(context).userToken;
    if (userToken == null) {
      throw Exception("You are not logged in");
    }
    return userToken;
  }

  Future<UserToken> login(String email, String password) async {
    UserToken userToken = await _mapRichApi.login(email, password);
    return userToken;
  }

  Future<int> verification(String email) async {
    return _mapRichApi.verificationCode(email);
  }

  Future<String> register(
      String email, String password, int verificationCode, String invitationCode, String fundPassword) async {
    return await _mapRichApi.signUp(email, password, verificationCode, invitationCode, fundPassword);
  }

  Future<CommonResponse> resetPassword(String email, String password, int verificationCode) async {
    CommonResponse commonResponse = await _mapRichApi.resetPassword(email, password, verificationCode);
    return commonResponse;
  }

  Future<CommonResponse> resetFundPassword(
      String email, String loginPassword, String fundPassword, int verificationCode) async {
    CommonResponse commonResponse =
        await _mapRichApi.resetFundPassword(email, loginPassword, fundPassword, verificationCode);
    return commonResponse;
  }

  ///充值支付确认V2
  Future<ResponseEntity<dynamic>> confirmRechargeV2(double balance) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.rechargePayV2(token: userToken.token, balance: balance);
  }

  Future checkIn() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    await _mapRichApi.checkIn(userToken.token, userToken.userId);
  }

  static Future checkInV2(String type) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    await _mapRichApi.checkInV2(userToken.token, userToken.userId, type);
  }

  Future<FundToken> getFundToken(String password) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.getFundToken(userToken.token, userToken.userId, password);
  }

  Future<UserEthAddress> getUserEthAddress() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.getUserEthAddress(userToken.token, userToken.userId);
  }

  Future<int> checkInCount() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    int count = await _mapRichApi.checkInCount(userToken.token, userToken.userId);
    return count;
  }

  Future<CheckInModel> checkInCountV2() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    CheckInModel checkInModel = await _mapRichApi.checkInCountV2(userToken.token, userToken.userId);
    return checkInModel;
  }

  Future<UserInfo> getUserInfo(UserToken userToken) async {
    UserInfo userInfo = await _mapRichApi.getUserInfo(userToken.token, userToken.userId);
    return userInfo;
  }

  Future<PageResponse<PowerDetail>> getPowerList(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<PowerDetail> pageResponse = await _mapRichApi.getPowerList(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<PageResponse<CheckinHistory>> getHistoryList(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<CheckinHistory> pageResponse =
        await _mapRichApi.getHistoryList(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<PageResponse<CheckinHistory>> getHistoryListV2(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<CheckinHistory> pageResponse =
        await _mapRichApi.getHistoryListV2(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<PageResponse<PromotionInfo>> getPromotionList(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<PromotionInfo> pageResponse =
        await _mapRichApi.getPrmotionsList(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<List<ContractInfo>> getContractList() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<ContractInfo> contractList = await _mapRichApi.getContractList(userToken.token);
    return contractList;
  }

  Future<List<ContractInfoV2>> getContractListV2() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<ContractInfoV2> contractList = await _mapRichApi.getContractListV2(userToken.token);
    return contractList;
  }

  Future<List<MortgageInfo>> getMortgageList() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<MortgageInfo> mortgageList = await _mapRichApi.getMortgageList(userToken.token);
    return mortgageList;
  }

  Future<List<MortgageInfoV2>> getMortgageListV2() async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<MortgageInfoV2> mortgageList = await _mapRichApi.getMortgageListV2(userToken.token);
    return mortgageList;
  }

  Future<List<BillInfo>> getDailyBillDetail(int id, int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<BillInfo> billList = await _mapRichApi.getDailyBillDetail(userToken.token, id, page);
    return billList;
  }

  Future<List<BillInfo>> getBillList(int page, {DailyBillsType type = DailyBillsType.all}) async {
    var typeString = type.toString().split('.').last;
    print('[Servece_api] getBillList, type:${type}, typeString: ${typeString}');

    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<BillInfo> billList = await _mapRichApi.getBillList(userToken.token, page, typeString);
    return billList;
  }

//  Future saveUserEmailToSharedpref(String email) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString(SHARED_PREF_USER_EMAIL_KEY, email);
//  }
//
//  Future saveUserTokenToSharedpref(UserToken userToken) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString(SHARED_PREF_USER_TOKEN_KEY, json.encode(userToken.toJson()));
//  }
//
//  Future<String> getUserEmailFromSharedpref() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String email = prefs.getString(SHARED_PREF_USER_EMAIL_KEY);
//    return email;
//  }

  ///订单创建
  Future<PayOrder> createOrder({@required int contractId}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createOrder(contractId: contractId, token: userToken.token);
  }

  // V2
  Future<PayOrder> createOrderV2({@required int contractId}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createOrderV2(contractId: contractId, token: userToken.token);
  }

  ///订单体验创建
  Future<PayOrder> createExperienceOrder({@required int contractId, @required int count}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createExperienceOrderV2(contractId: contractId, count: count, token: userToken.token);
  }

  ///订单免费创建
  Future<PayOrder> createFreeOrder({@required int contractId}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createFreeOrder(contractId: contractId, token: userToken.token);
  }

  //充值订单创建
  Future<RechargeOrderInfo> createRechargeOrder({@required double amount}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createRechargeOrder(amount: amount, token: userToken.token);
  }

  ///支付确认
  Future<ResponseEntity<dynamic>> confirmPay(
      {@required int orderId, @required String payType, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.confirmPay(
        orderId: orderId, payType: payType, token: userToken.token, fundToken: fundToken);
  }

  // V2
  Future<ResponseEntity<dynamic>> confirmPayV2(
      {@required int orderId, @required String payType, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.confirmPayV2(
        orderId: orderId, payType: payType, token: userToken.token, fundToken: fundToken);
  }

  // V3
  Future<ResponseEntity<dynamic>> confirmPayV3(
      {@required int orderId, @required String payType, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.confirmPayV3(
        orderId: orderId, payType: payType, token: userToken.token, fundToken: fundToken);
  }

  ///体验支付确认
  Future<ResponseEntity<dynamic>> confirmExperiencePay(
      {@required int orderId, @required String payType, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.confirmExperiencePayV2(
        orderId: orderId, payType: payType, token: userToken.token, fundToken: fundToken);
  }

  ///充值支付确认
  Future<ResponseEntity<dynamic>> confirmRecharge({@required int orderId}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.confirmRecharge(orderId: orderId, token: userToken.token);
  }

  ///行情
  Future<Quotes> quotes() async {
    return await _mapRichApi.quotes();
  }

  ///体验详情
  Future<ExperienceInfoV2> experience(@required int contractId) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.experience(contractId, userToken.token);
  }

  ///提币信息
  Future<WithdrawalInfo> withdrawalInfo(String type) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.withdrawalInfo(token: userToken.token, type: type);
  }

  ///提币
  Future<dynamic> withdrawalApply(
      {@required double amount, @required String address, @required String fundToken, @required int type}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.withdrawalApply(
        address: address, amount: amount, token: userToken.token, fundToken: fundToken, type: type);
  }

  Future<dynamic> withdrawalApplyV2(
      {@required double amount, @required String address, @required String fundToken, @required int type}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.withdrawalApplyV2(
        address: address, amount: amount, token: userToken.token, fundToken: fundToken, type: type);
  }

//  Future<UserToken> getUserTokenFromSharedpref() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String data = prefs.getString(SHARED_PREF_USER_TOKEN_KEY);
//    if (data == null) {
//      return null;
//    }
//    var map = json.decode(data);
//    return UserToken.fromJson(map);
//  }

//  Future signOut() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.remove(SHARED_PREF_USER_EMAIL_KEY);
//    await prefs.remove(SHARED_PREF_USER_TOKEN_KEY);
//  }

  Future<PageResponse<NodeMortgageInfo>> getNodeMortgageList(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<NodeMortgageInfo> pageResponse = await _mapRichApi.getNodeMortgageList(userToken.token, page);
    return pageResponse;
  }

  /// 获取用户等级
  Future<List<UserLevelInfo>> getUserLevelInfoList() async {
    List<UserLevelInfo> billList = await _mapRichApi.getUserLevelList();
    return billList;
  }

  ///获取提币记录
  Future<PageResponse<WithdrawalInfoLog>> getWithdrawalLogList(int page) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<WithdrawalInfoLog> pageResponse = await _mapRichApi.getWithdrawalLogList(userToken.token, page);
    return pageResponse;
  }

  ///抵押
  Future<dynamic> mortgage({@required int confId, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.mortgage(token: userToken.token, confId: confId, fundToken: fundToken);
  }

  ///抵押抢注
  Future<dynamic> mortgageSnapUp({@required int confId, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.mortgageSnapUp(token: userToken.token, confId: confId, fundToken: fundToken);
  }

  ///赎回
  Future<dynamic> redemption({@required int id, @required String fundToken}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.redemption(token: userToken.token, id: id, fundToken: fundToken);
  }

  Future<String> getDianpingCookies() async {
    return await _mapRichApi.getDianpingCookies();
  }

  Future<ResponseEntity<dynamic>> postStakingRewardFreeze({@required int nodeId, @required String contractAddress, @required String walletAddress}) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.postStakingRewardFreeze(nodeId: nodeId, contractAddress: contractAddress, walletAddress: walletAddress, token: userToken.token);
  }

    ///附近可以分享的位置
  ///type:
  /// 1 美食
  /// 2 酒店
  /// 3 景点
  /// 4 停车场
  /// 5 加油站
  /// 6 银行
  /// 7 超市
  /// 8 商场
  /// 9 网吧
  /// 10 厕所
  Future<PhotoPoiListResultModel> searchByGaode({
    @required double lat,
    @required double lon,
    int type,
    double radius = 2000,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    UserToken userToken = getUserToken();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.searchByGaode(
      lat: lat,
      lon: lon,
      token: userToken.token,
      radius: radius,
      type: type,
      page: page,
      cancelToken: cancelToken,
    );
  }
}
