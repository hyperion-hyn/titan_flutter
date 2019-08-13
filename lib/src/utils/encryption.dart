import 'dart:math';

import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/plugins/titan_plugin.dart';

import 'package:titan/src/utils/open_location_code.dart' as locationCode;

Future<String> reEncryptPoi(Repository repository, IPoi poi, String remark) async {
  var message = _genMessage(poi, remark);
  var api = repository.api;
  Map<String, dynamic> rePubKeyMap = await api.getReEncryptPubKey();
  var pubKey = rePubKeyMap['public_key'];
  var kid = rePubKeyMap['kid'];
  var rand = '${DateTime.now().millisecondsSinceEpoch}:${Random().nextDouble()}';
  var cm_a = await TitanPlugin.encrypt(pubKey, rand);
  var ct_a = await TitanPlugin.encrypt(pubKey, message);
  if(cm_a == null || cm_a.isEmpty || ct_a == null || ct_a.isEmpty) {
    throw Exception('加密失败');
  }
  var expiracy = 3600; //1 day
  await api.storeCls(commitment: cm_a, ciphertext: ct_a, expiracy: expiracy, kid: kid);
  var kid_cmA = "${kid}_$cm_a";
  var shareCipherText = "${Const.TITAN_SHARE_URL_PREFIX}${Const.CIPHER_TOKEN_PREFIX}$kid_cmA";

  return shareCipherText;
}

Future<String> p2pEncryptPoi(String pubKey, IPoi poi, String remark) async {
  var message = _genMessage(poi, remark);
  var ciphertext = await TitanPlugin.encrypt(pubKey, message);
  if(ciphertext == null || ciphertext.isEmpty) {
    throw Exception('不是合法的公钥');
  }
  return "${Const.TITAN_SHARE_URL_PREFIX}${Const.CIPHER_TEXT_PREFIX}$ciphertext";
}

String _genMessage(IPoi poi, String remark) {
  var openLocationCode = locationCode.encode(poi.latLng.latitude, poi.latLng.longitude);
  return "${poi.name}-$openLocationCode-$remark"; //title-loc-remark
}