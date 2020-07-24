import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';

import '../../../global.dart';
import 'item_order.dart';

class ExchangeActiveOrderListPage extends StatefulWidget {
  final String market;

  ExchangeActiveOrderListPage(this.market);

  @override
  State<StatefulWidget> createState() {
    return ExchangeActiveOrderListPageState();
  }
}

class ExchangeActiveOrderListPageState
    extends State<ExchangeActiveOrderListPage>
    with AutomaticKeepAliveClientMixin {
  var exchangeApi = ExchangeApi(); 
  List<Order> _activeOrders = List();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      bloc: BlocProvider.of<SocketBloc>(context),
      listener: (ctx, state) {
        if (state is ChannelUserTickState) {
          var temOrders = List<Order>();
          state.response.forEach((entity) => {
            if ((entity as List<dynamic>).length >= 7 && (entity[2] == 0 || entity[2] == 1)){
              temOrders.add(Order.fromSocket(entity))}
          });

          if (temOrders.length > 0) {
            var temAddOrders = List<Order>();
            temOrders.forEach((temElement) {
              var isNewOrder = true;
              _activeOrders.forEach((actElement) {
                if(temElement.orderId == actElement.orderId){
                  print("update order");
                  isNewOrder = false;
                  actElement = temElement;
                }
              });
              if(isNewOrder){
                temAddOrders.add(temElement);
              }
            });
            if(temAddOrders.length > 0){
              print("insert order");
              _activeOrders.insertAll(0, temAddOrders);
            }
            setState(() {

            });
//            print("!!!!!!!order= ${state.response}");
//            _currentOrders.clear();
//            _currentOrders.addAll(temOrders);
//            consignListController.add(contrConsignTypeRefresh);
          }
        }
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _activeOrders.length,
        itemBuilder: (ctx, index) => OrderItem(_activeOrders[index],revokeOrder: (orderEntity){

        },),
      ),
    );
  }

  _loadData() async {
    List<Order> orderList = await exchangeApi.getOrderList(widget.market, 1, 100, "active");
    _activeOrders.clear();
    _activeOrders.addAll(orderList);
    if (mounted) setState(() {});
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
