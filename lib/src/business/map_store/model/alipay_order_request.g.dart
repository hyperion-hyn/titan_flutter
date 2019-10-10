// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alipay_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlipayOrderResponse _$AlipayOrderResponseFromJson(Map<String, dynamic> json) {
  return AlipayOrderResponse(
      json['r7_TrxNo'] as String,
      json['rb_CodeMsg'] as String,
      json['r2_OrderNo'] as String,
      json['r3_Amount'] as String,
      json['r6_FrpCode'] as String,
      json['rc_Result'] as String,
      json['ra_Code'] as int,
      json['hmac'] as String,
      json['rd_Pic'] as String,
      json['r4_Cur'] as String,
      json['r5_Mp'] as String,
      json['r8_MerchantBankCode'] as String,
      json['r0_Version'] as String,
      json['r1_MerchantNo'] as String);
}

Map<String, dynamic> _$AlipayOrderResponseToJson(
        AlipayOrderResponse instance) =>
    <String, dynamic>{
      'r7_TrxNo': instance.trxNo,
      'rb_CodeMsg': instance.codeMsg,
      'r2_OrderNo': instance.orderNo,
      'r3_Amount': instance.amount,
      'r6_FrpCode': instance.frpCode,
      'rc_Result': instance.result,
      'ra_Code': instance.code,
      'hmac': instance.hmac,
      'rd_Pic': instance.pic,
      'r4_Cur': instance.cur,
      'r5_Mp': instance.mp,
      'r8_MerchantBankCode': instance.merchantBackCode,
      'r0_Version': instance.version,
      'r1_MerchantNo': instance.merchantNo
    };
