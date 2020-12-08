import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'entity/rp_release_info.dart';

class RpLevelUpgradePage extends StatefulWidget {
  RpLevelUpgradePage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUpgradeState();
  }
}

class _RpLevelUpgradeState extends BaseState<RpLevelUpgradePage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _currentPage = 1;
  var _address = "";
  List<RpReleaseInfo> _dataList = [];

  int lastDay;
  int _currentSelectedIndex;

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#FFFFFF'),
      appBar: BaseAppBar(
        baseTitle: '升级量级',
        backgroundColor: HexColor('#FFFFFF'),
      ),
      body: _pageView(),
    );
  }

  _pageView() {
    return LoadDataContainer(
      bloc: _loadDataBloc,
      onLoadData: () async {
        getNetworkData();
      },
      onRefresh: () async {
        getNetworkData();
      },
      onLoadingMore: () {
        getMoreNetworkData();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '当前流通 20345 RP，百分比Y = 5%（5%单位粒度）',
                    style: TextStyle(
                      color: HexColor('#333333'),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //每行三列
                  childAspectRatio: 1.5, //显示区域宽高相等
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 5,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  bool isRecommend = index == 0;
                  bool isCurrent = index == 3;
                  bool isLastMost = index == 1;
                  String leftTagTitle = '';
                  if (isLastMost) {
                    leftTagTitle = '历史最高';
                  }

                  if (isCurrent) {
                    leftTagTitle = '当前量级';
                  }

                  bool isSelected = (_currentSelectedIndex != null && _currentSelectedIndex == index);
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Stack(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              onTap: () {
                                setState(() {
                                  _currentSelectedIndex = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? HexColor('#FFEAEA')
                                      : HexColor('#F6F6F6'),
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        '量级 ${index + 1}',
                                        style: TextStyle(
                                          color: HexColor('#333333'),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        left: 14,
                                        bottom: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            child: _columnWidget(
                                              '5 RP',
                                              '需燃烧',
                                            ),
                                            // child: _columnWidget('$totalTransmit RP', '总可传导'),
                                          ),
                                          Spacer(),
                                          _columnWidget(
                                            '5 RP',
                                            '最低持币 5*(1+Y)',
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (leftTagTitle?.isNotEmpty ?? false)
                              Positioned(
                                  left: 10,
                                  top: 6,
                                  child: Text(
                                    leftTagTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 10,
                                      color: isLastMost ? HexColor('#FF4C3B') : HexColor('#999999'),
                                    ),
                                  )),
                             Positioned(
                              bottom: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 3, 0, 0),
                                child: Center(
                                  child: Image.asset(
                                    "res/drawable/red_pocket_level_${!isSelected ? 'un_check' : 'check'}.png",
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRecommend)
                        Positioned(
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                                color: HexColor("#FF4C3B"), borderRadius: BorderRadius.all(Radius.circular(10.0))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                              child: Center(
                                child: Text(
                                  '推荐',
                                  style: TextStyle(
                                      fontSize: 8, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _columnWidget(
    String amount,
    String title,
  ) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: DefaultColors.color999,
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 14,
            color: DefaultColors.color333,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _confirmButtonWidget() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClickOvalButton(
                '增加持币',
                _confirmAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#2D99FF'), HexColor('#107EDC')],
                //isLoading: !_canCancel,
              ),
              SizedBox(width: 20,),
              ClickOvalButton(
                '升级',
                _confirmAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
                //isLoading: !_canCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _confirmAction() {}

  void getNetworkData() async {
    _currentPage = 1;

    try {
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        _dataList.addAll(netData);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
