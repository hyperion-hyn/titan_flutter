import 'package:json_annotation/json_annotation.dart';

part 'alipay_order_request.g.dart';

@JsonSerializable()
class AlipayOrderResponse {
  @JsonKey(name: "r7_TrxNo")
  final String trxNo;
  @JsonKey(name: "rb_CodeMsg")
  final String codeMsg;
  @JsonKey(name: "r2_OrderNo")
  final String orderNo;
  @JsonKey(name: "r3_Amount")
  final String amount;
  @JsonKey(name: "r6_FrpCode")
  final String frpCode;
  @JsonKey(name: "rc_Result")
  final String result;
  @JsonKey(name: "ra_Code")
  final int code;
  @JsonKey(name: "hmac")
  final String hmac;
  @JsonKey(name: "rd_Pic")
  final String pic;
  @JsonKey(name: "r4_Cur")
  final String cur;
  @JsonKey(name: "r5_Mp")
  final String mp;
  @JsonKey(name: "r8_MerchantBankCode")
  final String merchantBackCode;
  @JsonKey(name: "r0_Version")
  final String version;
  @JsonKey(name: "r1_MerchantNo")
  final String merchantNo;

  AlipayOrderResponse(this.trxNo, this.codeMsg, this.orderNo, this.amount,
      this.frpCode, this.result, this.code, this.hmac, this.pic, this.cur,
      this.mp, this.merchantBackCode, this.version, this.merchantNo);


  factory AlipayOrderResponse.fromJson(Map<String, dynamic> json) => _$AlipayOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AlipayOrderResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
