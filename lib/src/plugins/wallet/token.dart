import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

part 'token.g.dart';

@JsonSerializable()
class AssetToken {
  final int decimals;
  final String name;
  final String symbol;
  final String logo;
  final String contractAddress;

  const AssetToken({this.name, this.decimals, this.contractAddress, this.symbol, this.logo});

  @override
  String toString() {
    return 'AssetToken{decimals: $decimals, name: $name, symbol: $symbol, logo: $logo, contractAddress: $contractAddress}';
  }

  factory AssetToken.fromJson(Map<String, dynamic> json) => _$AssetTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTokenToJson(this);
}

///available tokens
class SupportedTokens {
  static const BTC = const AssetToken(
    name: 'BITCOIN',
    decimals: 8,
//    logo: 'https://www.altilly.com/assets/img/BTC_large.png',
    logo: 'res/drawable/ic_btc_logo_large.png',
    symbol: 'BTC',
  );

  static const ETHEREUM = const AssetToken(
    name: 'Ethereum',
    decimals: 18,
    contractAddress: null,
    logo: 'res/drawable/ic_eth.png',
    symbol: 'ETH',
  );

  static const HYN_Atlas = const AssetToken(
    name: "Hyperion",
    decimals: 18,
    contractAddress: null,
    logo: "res/drawable/ic_hyn_logo_new.png",
    symbol: 'HYN',
  );

  static const HYN_RP_ERC30 = const AssetToken(
    name: "Red Package",
    decimals: 18,
    contractAddress: '0x8da841502526591599d5483EbEAe66e9fEA57430',
    logo: "res/drawable/ic_wallet_image_rp_hrc30.png",
    symbol: 'RP',
  );

  static const HYN_RP_ERC30_ROPSTEN = const AssetToken(
    name: "Red Package",
    decimals: 18,
    contractAddress: '0x8da841502526591599d5483EbEAe66e9fEA57430',
    logo: "res/drawable/ic_wallet_image_rp_hrc30.png",
    symbol: 'RP',
  );

  static const HYN_ERC20 = const AssetToken(
    name: 'Hyperion',
    decimals: 18,
    contractAddress: '0xe99a894a69d7c2e3c92e61b64c505a6a57d2bc07',
    logo: "res/drawable/ic_hyn_logo_empty.png",
    symbol: 'HYN ERC20',
  );

  static const USDT_ERC20 = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
//    logo: 'https://tether.to/wp-content/uploads/2015/02/Tether_logo_dm-e1537976324456.png',
    logo: 'res/drawable/usdt_logo.png',
    contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
    symbol: 'USDT',
  );

  static const USDT_ERC20_ROPSTEN = const AssetToken(
    name: 'Tether USD',
    decimals: 6,
    logo: 'res/drawable/usdt_logo.png',
    contractAddress: '0xE82B8Eb1ce4684475eFc1655928dD012fb5Fa0Bb',
    symbol: 'USDT',
  );

  static const HYN_ROPSTEN = const AssetToken(
      name: 'Hyperion ROPSTEN',
      decimals: 18,
      //contractAddress: '0xaebbada2bece10c84cbeac637c438cb63e1446c9',
      contractAddress: '0xE2Ba724b516Bacca8646Ad72796d23Af39C610A6',
      logo: "res/drawable/ic_hyn_logo_empty.png",
      symbol: 'HYN ERC20');

  static const HYN_RINKEBY = const AssetToken(
      name: 'Hyperion RINKEBY',
      decimals: 18,
      contractAddress: '0x97B9e0EfeF243720FB024C823a39cBD73C25D601',
      logo: "res/drawable/ic_hyn_logo_new.png",
      symbol: 'HYN ERC20');

  static final HYN_LOCAL = AssetToken(
      name: 'Hyperion LOCAL',
      decimals: 18,
      contractAddress: ContractTestConfig.hynContractAddress,
      logo: "res/drawable/ic_hyn_logo_new.png",
      symbol: 'HYN ERC20');

  static List<AssetToken> allContractTokens(EthereumNetType netType) {
    if (netType == EthereumNetType.main) {
      return [HYN_ERC20, USDT_ERC20, HYN_RP_ERC30];
    } else if (netType == EthereumNetType.ropsten) {
      return [HYN_ROPSTEN, USDT_ERC20_ROPSTEN, HYN_RP_ERC30_ROPSTEN];
    } else if (netType == EthereumNetType.rinkeby) {
      return [HYN_RINKEBY];
    } else {
      return [HYN_LOCAL];
    }
  }
}
