import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'map3_node_public_widget.dart';

class Map3NodeUserListPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;
  final LoadDataBloc loadDataBloc;

  Map3NodeUserListPage(this.map3infoEntity, this.loadDataBloc);

  @override
  State<StatefulWidget> createState() {
    return Map3NodeUserListPageState();
  }
}

class Map3NodeUserListPageState extends State<Map3NodeUserListPage> {
  List<Map3UserEntity> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  Map3InfoEntity _map3infoEntity;
  String get _nodeId => _map3infoEntity?.nodeId ?? '';

  int _currentPage = 1;
  //int _pageSize = 30;
  final AtlasApi _atlasApi = AtlasApi();
  String get _nodeCreatorAddress => _map3infoEntity?.creator ?? '';
  var _walletAddress = "";

  @override
  void initState() {
    super.initState();

    _map3infoEntity = widget?.map3infoEntity;

    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
    _walletAddress = _wallet?.getEthAccount()?.address ?? "";

    if (widget?.loadDataBloc != null) {
      widget.loadDataBloc.listen((state) {
        if (state is RefreshSuccessState) {
          _refreshData();
        }
      });
    } else {
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _dataList.length * 85.0,
      child: LoadDataContainer(
          bloc: _loadDataBloc,
          onLoadData: () async {
            await _refreshData();
          },
          onRefresh: () async {
            await _refreshData();
          },
          onLoadingMore: () {
            _loadMoreData();
            setState(() {});
          },
          child: CustomScrollView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Text('共 ${_dataList?.length ?? 0}个',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: HexColor('#999999'),
                      )),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var item = _dataList[index];

                    var itemAddress = item.address.toLowerCase();
                    var isYou = itemAddress == _walletAddress;
                    var isCreator = itemAddress == _nodeCreatorAddress.toLowerCase();
                    var recordName =
                        "${isCreator && !isYou ? " (${S.of(Keys.rootKey.currentContext).creator})" : ""}${!isCreator && isYou ? " (${S.of(Keys.rootKey.currentContext).you})" : ""}${isCreator && isYou ? " (${S.of(Keys.rootKey.currentContext).creator})" : ""}";

                    var amount = FormatUtil.stringFormatCoinNum(
                        ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item.staking)).toString()) +
                        ' HYN';

                    return Container(
                      color: Colors.white,
                      child: Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: iconWidget("", item.name, item.address, isCircle: true),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: RichText(
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                    text: item.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: HexColor("#000000"),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: recordName,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: HexColor("#999999"),
                                                            fontWeight: FontWeight.w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 8.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                shortBlockChainAddress(
                                                    "${WalletUtil.ethAddressToBech32Address(itemAddress)}",
                                                    limitCharsLength: 8),
                                                style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    amount,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor('#333333'),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 40,
                            right: 8,
                            child: Container(
                              height: 0.5,
                              color: DefaultColors.colorf5f5f5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: _dataList.length))
            ],
          )),
    );
  }

  Future _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    var networkList = await _atlasApi.getMap3UserList(
      _nodeId,
      page: _currentPage,
    );
    if (networkList != null) {
      _dataList.addAll(networkList);
    }

    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    _currentPage++;

    var networkList = await _atlasApi.getMap3UserList(
      _nodeId,
      page: _currentPage,
    );

    if (networkList != null) {
      _dataList.addAll(networkList);
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());

    if (networkList.length > 0) {
      widget.loadDataBloc.add(LoadingMoreSuccessEvent());
    } else {
      widget.loadDataBloc.add(LoadMoreEmptyEvent());
    }

    if (mounted) setState(() {});
  }
}
