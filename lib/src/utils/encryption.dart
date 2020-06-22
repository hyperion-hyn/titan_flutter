import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/entity/poi/mapbox_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/generated/l10n.dart';

import '../global.dart';

Future<String> reEncryptPoi(
    Repository repository, IPoi poi, String remark) async {
  var message = _genMessage(poi, remark);
  var api = repository.api;
  Map<String, dynamic> rePubKeyMap = await api.getReEncryptPubKey();
  var pubKey = rePubKeyMap['public_key'];
  var kid = rePubKeyMap['kid'];
  var rand =
      '${DateTime.now().millisecondsSinceEpoch}:${Random().nextDouble()}';
  var cm_a = await TitanPlugin.encrypt(pubKey, rand);
  var ct_a = await TitanPlugin.encrypt(pubKey, message);
  if (cm_a == null || cm_a.isEmpty || ct_a == null || ct_a.isEmpty) {
    throw Exception(S.of(Keys.rootKey.currentContext).encrypt_error);
  }
  var expiracy = 24 * 3600; //1 day
  await api.storeCls(
      commitment: cm_a, ciphertext: ct_a, expiracy: expiracy, kid: kid);
  var kid_cmA = "${kid}_$cm_a";
  //var shareCipherText ="${Const.TITAN_SHARE_URL_PREFIX}${Const.CIPHER_TOKEN_PREFIX}$kid_cmA";
  var shareCipherText = "${Const.CIPHER_TOKEN_PREFIX}$kid_cmA";

  return shareCipherText;
}

Future<String> p2pEncryptPoi(String pubKey, IPoi poi, String remark) async {
  var message = _genMessage(poi, remark);
  var ciphertext = await TitanPlugin.encrypt(pubKey, message);
  if (ciphertext == null || ciphertext.isEmpty) {
    throw Exception(S.of(Keys.rootKey.currentContext).not_legal_public_key);
  }
  //return "${Const.TITAN_SHARE_URL_PREFIX}${Const.CIPHER_TEXT_PREFIX}$ciphertext";
  return "${Const.CIPHER_TEXT_PREFIX}$ciphertext";
}

String _genMessage(IPoi poi, String remark) {
//  var openLocationCode = locationCode.encode(poi.latLng.latitude, poi.latLng.longitude);
//  return "${poi.name}-$openLocationCode-${remark ?? ''}"; //title-loc-remark
  return "${poi.name}-${poi.latLng.latitude},${poi.latLng.longitude}-${remark ?? ''}"; //title-loc-remark
}

Future<IPoi> ciphertextToPoi(Repository repository, String ciphertext) async {
  var trimList = [
    Const.TITAN_SHARE_URL_PREFIX,
    Const.TITAN_SCHEMA,
    "://",
    "//",
    "/"
  ];
  for (var trimText in trimList) {
    if (ciphertext.startsWith(trimText)) {
      ciphertext = ciphertext.replaceFirst(trimText, "");
    }
  }
  logger.d('after cut ciphertext is: $ciphertext');

  var cmsg;
  if (ciphertext.startsWith(Const.CIPHER_TEXT_PREFIX)) {
    // p2p share
    ciphertext = ciphertext.substring(Const.CIPHER_TEXT_PREFIX.length);
    cmsg = await TitanPlugin.decrypt(ciphertext);
  } else if (ciphertext.startsWith(Const.CIPHER_TOKEN_PREFIX)) {
    // common share
    ciphertext = ciphertext.substring(Const.CIPHER_TOKEN_PREFIX.length);
    if (ciphertext.indexOf("_") > 0) {
      var kidCiphertextAry = ciphertext.split("_");
      var kid = kidCiphertextAry[0];
      ciphertext = kidCiphertextAry[1];
      var pubKey = await TitanPlugin.getPublicKey();
      try {
        var clsMap = await repository.api
            .getCls(commitment: ciphertext, pubkey: pubKey, kid: kid);
        var ct_b = clsMap['ct_b'];
        cmsg = await TitanPlugin.decrypt(ct_b);
      } catch (err) {
        logger.e(err);
      }
    }
  }

  if (cmsg != null) {
    var msgAry = cmsg.split("-");
    var name = msgAry[0];
    String coordinate = msgAry[1];

//    var codeArea = locationCode.decode(coordinate);
//    var latLng = LatLng(codeArea.center.latitude, codeArea.center.longitude);

    List<String> coordinates = coordinate.split(',');
    var latLng =
        LatLng(double.parse(coordinates[0]), double.parse(coordinates[1]));

    var word = "";
    if (msgAry.length > 2) {
      word = msgAry[2];
    }

    return MapBoxPoi(name: name, latLng: latLng, remark: word);
  }

  throw Exception(S.of(Keys.rootKey.currentContext).ciphertext_has_expired);
}
