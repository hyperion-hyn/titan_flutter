import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/exchange_detail/bloc/exchange_detail_bloc.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';

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

class ExchangeActiveOrderListPageState extends BaseState<ExchangeActiveOrderListPage>
    with AutomaticKeepAliveClientMixin, RouteAware {
  ExchangeDetailBloc exchangeDetailBloc = ExchangeDetailBloc();
  ExchangeModel exchangeModel;
  String userTickChannel;
  List<Order> _activeOrders = List();
  int consignPageSize = 1;
  bool consignIsLoading = true;
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  SocketBloc _socketBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
    _socketBloc = BlocProvider.of<SocketBloc>(context);
    if (exchangeModel.isActiveAccount()) {
      var symbolList = widget.market.split("/");
      userTickChannel = SocketConfig.channelUserTick(
          exchangeModel.activeAccount.id, "${symbolList[0].toLowerCase()}${symbolList[1].toLowerCase()}");
      _socketBloc.add(SubChannelEvent(channel: userTickChannel));
    }
    _loadDataBloc.add(LoadingEvent());
    consignLoadData();
    super.onCreated();
  }

  consignLoadData() async {
    consignPageSize = 1;
    await loadConsignList(widget.market, consignPageSize, _activeOrders);
    if (mounted) setState(() {});
    _loadDataBloc.add(RefreshSuccessEvent());
  }

  @override
  void didPopNext() {
    consignLoadData();
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
      _socketBloc.add(UnSubChannelEvent(channel: userTickChannel));
    }
    Application.routeObserver.unsubscribe(this);
    exchangeDetailBloc.close();
    _loadDataBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      bloc: _socketBloc,
      listener: (ctx, state) {
        consignListSocket(state, _activeOrders);
      },
      child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullDown: false,
          onLoadData: (){
          },
          onLoadingMore: () async {
            if(exchangeModel.isActiveAccount())  {
              consignPageSize ++;
              await loadMoreConsignList(_loadDataBloc, widget.market, consignPageSize, _activeOrders);
              setState(() {

              });
            }
          },
          child: SingleChildScrollView(child: orderListWidget(context,widget.market,consignIsLoading,_activeOrders))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future loadConsignList(String marketCoin, int pageNum, List<Order> _activeOrders) async {
  _activeOrders.clear();
  ExchangeApi exchangeApi = ExchangeApi();
  var orderList = await exchangeApi.getOrderList(marketCoin, pageNum, 20, "active");
  _activeOrders.addAll(orderList);
}

Future loadMoreConsignList(LoadDataBloc _loadDataBloc, String marketCoin, int pageNum, List<Order> _activeOrders) async {
  ExchangeApi exchangeApi = ExchangeApi();
  var orderList = await exchangeApi.getOrderList(marketCoin, pageNum, 20, "active");

  if (orderList.length == 0 && _activeOrders.length > 0) {
    _loadDataBloc.add(LoadMoreEmptyEvent());
  } else {
    _activeOrders.addAll(orderList);
    _loadDataBloc.add(LoadingMoreSuccessEvent());
  }
}

Widget orderListEmpty(BuildContext context){
  var exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 13,
        ),
        Image.asset("res/drawable/ic_consign_empty.png", width: 59, height: 64),
        SizedBox(
          height: 10,
        ),
        Text(
          exchangeModel.isActiveAccount() ? "暂无委托单" : "登录后查看委托单",
          style: TextStyle(fontSize: 14, color: HexColor("#999999")),
        )
      ],
    ),
  );
}

Widget orderListWidget(BuildContext context, String marketCoin, bool isLoading, List<Order> _activeOrders) {
  if(_activeOrders.length == 0){
    orderListEmpty(context);
  }
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: _activeOrders.length,
    itemBuilder: (ctx, index) => OrderItem(
      _activeOrders[index],
      revokeOrder: (Order orderEntity) async {
//        await exchangeApi.orderCancel(orderEntity.orderId);
      },
      market: marketCoin,
    ),
  );
}

consignListSocket(SocketState state, List<Order> _activeOrders) {
  if (state is ChannelUserTickState) {
    var netNewOrders = List<Order>();
    var netCancelOrders = List<Order>();
    var netCompOrders = List<Order>();
    state.response.forEach((entity) => {
          if ((entity as List<dynamic>).length >= 7 && (entity[2] == 0 || entity[2] == 1))
            {netNewOrders.add(Order.fromSocket(entity))}
          else if ((entity as List<dynamic>).length >= 7 && (entity[2] >= 3 && entity[2] <= 5))
            {netCancelOrders.add(Order.fromSocket(entity))}
          else if ((entity as List<dynamic>).length >= 7 && entity[2] == 2)
            {netCompOrders.add(Order.fromSocket(entity))}
        });

    if (netNewOrders.length > 0) {
      var temAddOrders = List<Order>();
      netNewOrders.forEach((netElement) {
        var isNewOrder = true;
        _activeOrders.forEach((actElement) {
          if (netElement.orderId == actElement.orderId) {
            isNewOrder = false;
            actElement = netElement;
          }
        });
        if (isNewOrder) {
          temAddOrders.add(netElement);
        }
      });

      if (temAddOrders.length > 0) {
        print("insert order");
        _activeOrders.insertAll(0, temAddOrders);
        Fluttertoast.showToast(msg: "下单成功");
      }
    }

    if (netCancelOrders.length > 0) {
      var temCancelOrders = List<Order>();

      netCancelOrders.forEach((netElement) {
        _activeOrders.forEach((actElement) {
          if (netElement.orderId == actElement.orderId) {
            temCancelOrders.add(actElement);
          }
        });
      });

      if (temCancelOrders.length > 0) {
        print("cancel order");
        temCancelOrders.forEach((element) {
          _activeOrders.remove(element);
        });
        Fluttertoast.showToast(msg: "订单撤销成功");
      }
    }

    if (netCompOrders.length > 0) {
      var temCompOrders = List<Order>();

      netCompOrders.forEach((netElement) {
        _activeOrders.forEach((actElement) {
          if (netElement.orderId == actElement.orderId) {
            temCompOrders.add(actElement);
          }
        });
      });

      if (temCompOrders.length > 0) {
        print("comp order");
        temCompOrders.forEach((element) {
          _activeOrders.remove(element);
        });
      }
      Fluttertoast.showToast(msg: "订单已完成");
    }
  }
}
