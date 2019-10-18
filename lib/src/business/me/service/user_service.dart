import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/business/me/api/map_rich_api.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/me/model/common_response.dart';
import 'package:titan/src/business/me/model/contract_info.dart';
import 'package:titan/src/business/me/model/contract_info_v2.dart';
import 'package:titan/src/business/me/model/mortgage_info.dart';
import 'package:titan/src/business/me/model/node_mortgage_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/pay_order.dart';
import 'package:titan/src/business/me/model/power_detail.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/model/purchase_order_info.dart';
import 'package:titan/src/business/me/model/quotes.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/model/user_level_info.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/model/withdrawal_info.dart';
import 'package:titan/src/business/me/model/withdrawal_info_log.dart';
import 'package:titan/src/domain/gaode_model.dart';

class UserService {
  MapRichApi _mapRichApi = MapRichApi();

  static const String SHARED_PREF_USER_EMAIL_KEY = "user_email";
  static const String SHARED_PREF_USER_TOKEN_KEY = "user_token";

  Future<UserToken> login(String email, String password) async {
    UserToken userToken = await _mapRichApi.login(email, password);
    await saveUserTokenToSharedpref(userToken);
    return userToken;
  }

  Future<int> verification(String email) async {
    return _mapRichApi.verificationCode(email);
  }

  Future<String> registoer(
      String email, String password, int verificationCode, String invitationCode, String fundPassword) async {
    return await _mapRichApi.signUp(email, password, verificationCode, invitationCode, fundPassword);
  }

  Future<CommonResponse> resetPassword(String email, String password, int verificationCode) async {
    CommonResponse commonResponse = await _mapRichApi.resetPassword(email, password, verificationCode);
    return commonResponse;
  }

  Future checkIn() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    await _mapRichApi.checkIn(userToken.token, userToken.userId);
  }

  Future<int> checkInCount() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    int count = await _mapRichApi.checkInCount(userToken.token, userToken.userId);
    return count;
  }

  Future<UserInfo> getUserInfo() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    UserInfo userInfo = await _mapRichApi.getUserInfo(userToken.token, userToken.userId);
    return userInfo;
  }

  Future<PageResponse<PowerDetail>> getPowerList(int page) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<PowerDetail> pageResponse = await _mapRichApi.getPowerList(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<PageResponse<PromotionInfo>> getPromotionList(int page) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<PromotionInfo> pageResponse =
        await _mapRichApi.getPrmotionsList(userToken.token, userToken.userId, page);
    return pageResponse;
  }

  Future<List<ContractInfo>> getContractList() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<ContractInfo> contractList = await _mapRichApi.getContractList(userToken.token);
    return contractList;
  }

  Future<List<ContractInfoV2>> getContractListV2() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<ContractInfoV2> contractList = await _mapRichApi.getContractListV2(userToken.token);
    return contractList;
  }

  Future<List<MortgageInfo>> getMortgageList() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<MortgageInfo> mortgageList = await _mapRichApi.getMortgageList(userToken.token);
    return mortgageList;
  }

  Future<List<BillInfo>> getBillList(int page) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    List<BillInfo> billList = await _mapRichApi.getBillList(userToken.token, page);
    return billList;
  }

  Future saveUserEmailToSharedpref(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SHARED_PREF_USER_EMAIL_KEY, email);
  }

  Future saveUserTokenToSharedpref(UserToken userToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SHARED_PREF_USER_TOKEN_KEY, json.encode(userToken.toJson()));
  }

  Future<String> getUserEmailFromSharedpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString(SHARED_PREF_USER_EMAIL_KEY);
    return email;
  }

  ///订单创建
  Future<PayOrder> createOrder({@required int contractId}) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.createOrder(contractId: contractId, token: userToken.token);
  }

  Future<PurchaseOrderInfo> createPurchaseOrder({@required double count}) async {
//    UserToken userToken = await getUserTokenFromSharedpref();
//    if (userToken == null) {
//      throw new Exception("not login");
//    }
//
//    return await _mapRichApi.createOrder(contractId: contractId, token: userToken.token);
    return PurchaseOrderInfo(
        "0xFD70c5DB8e4b3B88426CC3a8A495769A4fC99382",
        200,
        108,
        "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEAAQMAAABmvDolAAAABlBMVEX///8AAABVwtN+AAACpUlEQVR42uyYW8ojQQiFBbcluHXBbQkO59iZdMK8lgOhC36S1P89FF6OF3nOc57zw0e7OzOzPEM7vExLs7tjEQjR8O4MLQBZ4p24XASyM7y0tMTMwzzEE5e7AB5WZmL4wJ/+ByBEOzu7y2mibQA/yxtREpohHhr65c3TwBW0n+cfUX0QGGOFeeF52RM23wl8FtC59YK7OhQ2E9gtFgE8S7QDOdvl3YHsyZI9QMQ8Q5A2XrAW41XfQbsBmIhCRR0eg9NgKdP3I88D+CdUI/xyWTkl3RYBMYVvkK/e5ZnDdC0CUI+itZKKbloGTDaBDvNmZQ3Yy8Zo73jZAKasF9STNoN6ocLGHkDVxvsUL0XcwkxmugigpYF6J7OFRTWYw5tAwj9QERbVMljsHjELANS8p7Ch3wozQ9t1E7kFwLxgG/QXiW9jqVthWwBY3dHg1TwOGtYfQXsc0ISAGQs7a6yZMIlkFUCiIF7JdjCD7gJyHBC8rxs1BTpijJ7QG7EA+N9el2UEkZPdt8TZAMLQ6MBXyGQISon4KkDfNMceJhD8JbcGZAHAVxRTDiJo+cpG2jaBbo5ixkMxEZa3TYAZAw2XVx3x+jTUeQAdLpp+tN+Im4nbVYB9jUM2EDHT+GNQfw9i54EZgamcLCPOH7fEWQAuGQvDEEhr8dEZmwCumC34IExR7VgEmCJoNdH0xwwA+d1wHgZsBuJiDjU6fzbfvQnQQ/Zam0FJMJnd1f44wGoes5xAdatXEi0CI2TImJo10bUt+SAOA+z1cCfcGcaoWH5tkw4Dsx/j5hBva0QPsUUgX52+c1k0+yIK2SpACcfsIUjg7GIcLQNcVs0+V65x7MNQpwG2mmiwrkWqUUt9FUDQInuTnnKuSprT6RrwnOc85xfPnwAAAP//jrcJk78fR9gAAAAASUVORK5CYII=",
        0,
        "3511.975800000000108");
  }

  ///支付确认
  Future<ResponseEntity<dynamic>> confirmPay({@required int orderId, @required String payType}) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.confirmPay(orderId: orderId, payType: payType, token: userToken.token);
  }

  ///行情
  Future<Quotes> quotes() async {
    return await _mapRichApi.quotes();
  }

  ///提币信息
  Future<WithdrawalInfo> withdrawalInfo() async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.withdrawalInfo(token: userToken.token);
  }

  ///提币
  Future<dynamic> withdrawalApply({@required double amount, @required String address}) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }

    return await _mapRichApi.withdrawalApply(address: address, amount: amount, token: userToken.token);
  }

  Future<UserToken> getUserTokenFromSharedpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString(SHARED_PREF_USER_TOKEN_KEY);
    if (data == null) {
      return null;
    }
    var map = json.decode(data);
    return UserToken.fromJson(map);
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(SHARED_PREF_USER_EMAIL_KEY);
    await prefs.remove(SHARED_PREF_USER_TOKEN_KEY);
  }

  Future<PageResponse<NodeMortgageInfo>> getNodeMortgageList(int page) async {
    UserToken userToken = await getUserTokenFromSharedpref();
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
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    PageResponse<WithdrawalInfoLog> pageResponse = await _mapRichApi.getWithdrawalLogList(userToken.token, page);
    return pageResponse;
  }

  ///抵押
  Future<dynamic> mortgage({@required int confId}) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.mortgage(token: userToken.token, confId: confId);
  }

  ///赎回
  Future<dynamic> redemption({@required int id}) async {
    UserToken userToken = await getUserTokenFromSharedpref();
    if (userToken == null) {
      throw new Exception("not login");
    }
    return await _mapRichApi.redemption(token: userToken.token, id: id);
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
  Future<GaodeModel> searchByGaode({
    @required double lat,
    @required double lon,
    int type,
    double radius = 2000,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    UserToken userToken = await getUserTokenFromSharedpref();
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
