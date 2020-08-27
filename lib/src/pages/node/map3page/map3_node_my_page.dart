import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'map3_node_list_page.dart';

class Map3NodeMyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeMyState();
  }
}

class _Map3NodeMyState extends State<Map3NodeMyPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<MyContractModel> _contractTypeModels;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_contractTypeModels?.isEmpty ?? true) {
      _contractTypeModels = [
        MyContractModel(S.of(context).my_initiated_map_contract, MyContractType.create),
        MyContractModel(S.of(context).my_join_map_contract, MyContractType.join)
      ];
      _tabController = TabController(length: _contractTypeModels.length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: BaseAppBar(
       baseTitle:S.of(context).my_contract
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      //indicatorColor: Theme.of(context).primaryColor,
                      indicatorPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      indicatorColor: HexColor("#228BA1"),
                      indicatorWeight: 3,
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: HexColor("#333333"),
                      indicatorSize: TabBarIndicatorSize.label,
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
            ),
            Expanded(
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
            ),
          ],
        ),
      ),
    );
  }
}





