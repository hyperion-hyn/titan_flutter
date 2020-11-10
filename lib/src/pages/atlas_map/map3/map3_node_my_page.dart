import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_reward_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../env.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_list_page.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeMyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeMyState();
  }
}

class _Map3NodeMyState extends BaseState<Map3NodeMyPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<MyContractModel> _contractTypeModels;
  UserRewardEntity _rewardEntity;
  AtlasApi _atlasApi = AtlasApi();
  AllPageState currentState = LoadingState();

  var _walletName = "";
  var _address = "";
  var _balance = "0";
  var _balanceValue = "0";

  Map<String, dynamic> _rewardMap = {};

  final client = WalletUtil.getWeb3Client(true);
  AtlasApi api = AtlasApi();

  @override
  void initState() {
    super.initState();

    // client.printErrors = true;
  }

  @override
  void dispose() {
    super.dispose();

    print("[Map3NodeMyPage]  dispose!!!");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void onCreated() {
    super.onCreated();

    if (_contractTypeModels?.isEmpty ?? true) {
      _contractTypeModels = [
        MyContractModel(S.of(context).my_initiated_map_contract, MyContractType.create),
        MyContractModel(S.of(context).my_join_map_contract, MyContractType.join)
      ];
      _tabController = TabController(length: _contractTypeModels.length, vsync: this);
    }

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _walletName = activatedWallet?.wallet?.keystore?.name ?? "";
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";

    getNetworkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: BaseAppBar(
        baseTitle: S.of(context).my_nodes,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              // Application.router
              //     .navigateTo(context, Routes.map3node_my_page_v8);

              Application.router.navigateTo(context, Routes.map3node_my_page_reward);
            },
            child: Text(
              // S.of(context).old_map3,
              '提取记录',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: _pageView(context),
    );
  }

  _pageView(BuildContext context) {
    if (currentState != null || _rewardEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(currentState, () {
          if (mounted) {
            setState(() {
              currentState = LoadingState();
            });
          }

          getNetworkData();
        }),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _myProfitWidget(),
          _tabBarWidget(),
          _childrenWidget(),
        ],
      ),
    );
  }

  void getNetworkData() async {
    try {
      _rewardEntity = await _atlasApi.getRewardInfo(_address);
      print("[my] _address:$_address");

      _rewardMap = await client.getAllMap3RewardByDelegatorAddress(
        EthereumAddress.fromHex(_address),
      );

      Decimal value = Decimal.parse('0');
      if (_rewardMap?.values?.isNotEmpty ?? false) {
        BigInt totalReward = BigInt.from(0);
        for (var value in _rewardMap?.values) {
          var source = value ?? "0";
          var bigIntValue = BigInt.tryParse(source) ?? BigInt.from(0);
          totalReward += bigIntValue;
        }
        value = ConvertTokenUnit.weiToEther(weiBigInt: totalReward);
      }
      print("[my] _rewardMap:$_rewardMap");

      _balance = "${FormatUtil.formatPrice(value.toDouble() ?? 0)}";
      _balanceValue = "${value.toDouble()}";

      if (mounted) {
        setState(() {
          currentState = null;
        });
      }
    } catch (e) {
      print(e);

      if (mounted) {
        setState(() {
          currentState = LoadFailState();
        });
      }
    }
  }

  _myProfitWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  //color: Colors.black12,
                  //blurRadius: 8.0,
                  color: HexColor("#000000").withOpacity(0.06),
                  blurRadius: 16.0,
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 20, top: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Text(
                    _balance,
                    style: TextStyle(
                      color: HexColor("#228BA1"),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    S.of(context).current_reward,
                    style: TextStyle(
                      color: HexColor("#333333"),
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                /*
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    color: HexColor("#F2F2F2"),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "历史奖励",
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor("#333333"),
                          ),
                          children: [
                            TextSpan(
                              text: " " + "20,492",
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#333333"),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                */
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 25),
                  child: ClickOvalButton(
                    S.of(context).collect_reward,
                    () {
                      _showAlertView();
                    },
                    height: 32,
                    width: 160,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _tabBarWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              indicatorColor: HexColor("#228BA1"),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: HexColor("#333333"),
              tabs: _contractTypeModels
                  .map((MyContractModel model) => Tab(
                        child: Text(
                          model.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  _childrenWidget() {
    return Expanded(
      child: RefreshConfiguration.copyAncestor(
        enableLoadingWhenFailed: true,
        context: context,
        headerBuilder: () => WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        footerTriggerDistance: 30.0,
        child: TabBarView(
          controller: _tabController,
          //physics: NeverScrollableScrollPhysics(),
          children: _contractTypeModels.map((model) => Map3NodeListPage(model)).toList(),
        ),
      ),
    );
  }

  _showAlertView() {
    var count = _rewardMap?.values?.length ?? 0;
    if (count == 0) {
      Fluttertoast.showToast(msg: S.of(context).current_reward_zero);
      return;
    }

    var now = DateTime.now().millisecondsSinceEpoch;
    var isOver6second = now - lastCollectDate > 6000;
    //print("isOver6second1: $isOver6second, lastCollectDate:$lastCollectDate, now:$now");
    if (!isOver6second) {
      Fluttertoast.showToast(msg: '提取申请正处理中，请稍后再发起新的提取请求！');
      return;
    }

    var preText = count != 0 ? "${S.of(context).you_create_or_join_node('${_rewardMap?.values?.length ?? 0}')}，" : "";

    UiUtil.showAlertView(context,
        title: S.of(context).collect_reward,
        actions: [
          ClickOvalButton(
            S.of(context).confirm_collect,
            () {
              Navigator.pop(context);

              var entity = PledgeMap3Entity();
              var message = ConfirmCollectMap3NodeMessage(
                entity: entity,
                amount: _balanceValue,
                addressList: _rewardMap?.keys?.map((e) => e.toString())?.toList() ?? [],
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map3NodeConfirmPage(
                      message: message,
                    ),
                  ));
            },
            width: 200,
            height: 38,
            fontSize: 16,
          ),
        ],
        content: S.of(context).confirm_collect_reward_to_wallet(preText, _balance),
        boldContent: "($_walletName)",
        boldStyle: TextStyle(
          color: HexColor("#999999"),
          fontSize: 12,
          height: 1.8,
        ),
        suffixContent: " ？");
  }
}
