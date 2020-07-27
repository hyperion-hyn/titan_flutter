import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/application.dart';
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
    extends BaseState<ExchangeActiveOrderListPage>
    with AutomaticKeepAliveClientMixin,RouteAware {
  var exchangeApi = ExchangeApi(); 
  List<Order> _activeOrders = List();
  ExchangeModel exchangeModel;
  String userTickChannel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    exchangeModel = ExchangeInheritedModel
        .of(context)
        .exchangeModel;
    if (exchangeModel.isActiveAccount()) {
      var symbolList = widget.market.split("/");
      userTickChannel = SocketConfig.channelUserTick(exchangeModel.activeAccount.id, "${symbolList[0].toLowerCase()}${symbolList[1].toLowerCase()}");
      BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: userTickChannel));
    }
    _loadData();
    super.onCreated();
  }

  @override
  void didPopNext() {
    print("sub didPopNext");
    _loadData();
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    if (exchangeModel.isActiveAccount()) {
      BlocProvider.of(context).add(UnSubChannelEvent(channel: userTickChannel));
    }
    Application.routeObserver.unsubscribe(this);

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
            var temCancelOrders = List<Order>();
            temOrders.forEach((temElement) {
              var isNewOrder = true;
              _activeOrders.forEach((actElement) {
                if(temElement.orderId == actElement.orderId){
                  print("update order");
                  if(int.parse(temElement.status) > 2){
                    temCancelOrders.add(actElement);
                  }else{
                    isNewOrder = false;
                    actElement = temElement;
                  }
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
            if(temCancelOrders.length > 0){
              temCancelOrders.forEach((element) {
                _activeOrders.remove(element);
              });
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
        itemBuilder: (ctx, index) => OrderItem(_activeOrders[index],revokeOrder: (Order orderEntity) async {
          await exchangeApi.orderCancel(orderEntity.orderId);
//          var result = await exchangeApi.orderCancel(orderEntity.orderId);
//          if(result is Map && result["errorCode"] == 0){
//          }
        },market: widget.market,),
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
