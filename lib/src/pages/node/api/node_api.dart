import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'node_http.dart';

class NodeApi {
  Map<String, dynamic> getOptionHeader({hasLang = false, hasAddress = false}) {
    if (!hasLang && !hasAddress) {
      return null;
    }
    Map<String, dynamic> headMap = Map();

    headMap.putIfAbsent("appSource", () => Config.APP_SOURCE);

    if (hasAddress) {
      var activeWalletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      var address = activeWalletVo.wallet.getEthAccount().address;
      if (activeWalletVo != null && (address?.isNotEmpty?? false)) {
        headMap.putIfAbsent("Address", () => address);
      }
    }

    if (hasLang) {
      var language = SettingInheritedModel.of(Keys.rootKey.currentContext).netLanguageCode;
      if (language?.isNotEmpty ?? false) {
        headMap.putIfAbsent("Lang", () => language);
      }
    }

    return headMap;
  }


  static List<NodeProviderEntity> _providerList;
  static Future<Regions> getProviderEntity(String id) async {
    if (id?.isEmpty ?? true) {
      return null;
    }

    if (_providerList?.isEmpty ?? true) {
      _providerList = await NodeApi().getNodeProviderList();
    }

    Regions _selectedRegion;
    if (_providerList.isNotEmpty) {
      var selectProviderEntity = _providerList[0];
      for (var region in (selectProviderEntity?.regions ?? [])) {
        if (region.id == id) {
          _selectedRegion = region;
          break;
        }
      }
    }
    return _selectedRegion;
  }

  Future<List<NodeProviderEntity>> getNodeProviderList() async {
    var nodeProviderList =
    await NodeHttpCore.instance.getEntity("/nodes/providers", EntityFactory<List<NodeProviderEntity>>((data) {
      return (data as List).map((dataItem) => NodeProviderEntity.fromJson(dataItem)).toList();
    }), options: RequestOptions(headers: getOptionHeader(hasLang: true)));

    return nodeProviderList;
  }
}
