import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
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
    if (exchangeModel.isActiveAccount() && widget.market.isNotEmpty) {
      var symbolList = widget.market.split("/");
      userTickChannel = SocketConfig.channelUserTick(
          exchangeModel.activeAccount.id, "${symbolList[0].toLowerCase()}${symbolList[1].toLowerCase()}");
      _socketBloc.add(SubChannelEvent(channel: userTickChannel));
    } else if (exchangeModel.isActiveAccount()) {
      _socketBloc
          .add(SubChannelEvent(channel: SocketConfig.channelUserTick(exchangeModel.activeAccount.id, "hynusdt")));
      _socketBloc.add(SubChannelEvent(channel: SocketConfig.channelUserTick(exchangeModel.activeAccount.id, "hyneth")));
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
        bool isRefresh = consignListSocket(context, state, _activeOrders, false);
        if (isRefresh) {
          setState(() {});
        }
      },
      child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullDown: false,
          enablePullUp: exchangeModel.isActiveAccount(),
          onLoadData: () {},
          onLoadingMore: () async {
            if (exchangeModel.isActiveAccount()) {
              consignPageSize++;
              await loadMoreConsignList(_loadDataBloc, widget.market, consignPageSize, _activeOrders);
            } else {
              _loadDataBloc.add(LoadingMoreSuccessEvent());
            }
            setState(() {});
          },
          child: currentPageList()),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget currentPageList() {
    if (_activeOrders.length == 0) {
      return orderListEmpty(context);
    }
    return SingleChildScrollView(child: orderListWidget(context, widget.market, consignIsLoading, _activeOrders));
  }
}

Future loadConsignList(String marketCoin, int pageNum, List<Order> _activeOrders) async {
  _activeOrders.clear();
  ExchangeApi exchangeApi = ExchangeApi();
  var orderList = await exchangeApi.getOrderList(marketCoin, pageNum, 20, "active");
  _activeOrders.addAll(orderList);
}

Future loadMoreConsignList(
    LoadDataBloc _loadDataBloc, String marketCoin, int pageNum, List<Order> _activeOrders) async {
  ExchangeApi exchangeApi = ExchangeApi();
  var orderList = await exchangeApi.getOrderList(marketCoin, pageNum, 20, "active");

  if (orderList.length == 0 && _activeOrders.length > 0) {
    _loadDataBloc.add(LoadMoreEmptyEvent());
  } else {
    _activeOrders.addAll(orderList);
    _loadDataBloc.add(LoadingMoreSuccessEvent());
  }
}

Widget orderListEmpty(BuildContext context) {
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
          exchangeModel.isActiveAccount() ? S.of(context).no_orders : S.of(context).view_order_after_login,
          style: TextStyle(fontSize: 14, color: HexColor("#999999")),
        ),
        SizedBox(
          height: 13,
        ),
      ],
    ),
  );
}

Widget orderListWidget(BuildContext context, String marketCoin, bool isLoading, List<Order> _activeOrders) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: _activeOrders.length,
    itemBuilder: (ctx, index) => OrderItem(
      _activeOrders[index],
      revokeOrder: (Order orderEntity) async {
        ExchangeApi exchangeApi = ExchangeApi();
        try {
          orderEntity.status = "-1";
          await exchangeApi.orderCancel(orderEntity.orderId);
          Future.delayed(Duration(milliseconds: 2000), () {
            BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
          });
        } catch (error) {
          if (error is HttpResponseCodeNotSuccess) {
            Fluttertoast.showToast(msg: error.message);
          }
        }
      },
    ),
  );
}

bool consignListSocket(BuildContext context, SocketState state, List<Order> _activeOrders, bool showToast) {
  if (state is ChannelUserTickState) {
    var netNewOrders = List<Order>();
    var netUpdateOrders = List<Order>();
    var netCancelOrders = List<Order>();
    var netCompOrders = List<Order>();
    state.response.forEach((entity) => {
          if ((entity as List<dynamic>).length >= 7 && (entity[2] == 0))
            {netNewOrders.add(Order.fromSocket(entity))}
          else if ((entity as List<dynamic>).length >= 7 && (entity[2] == 1))
            {netUpdateOrders.add(Order.fromSocket(entity))}
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
        /*if(showToast) {
          Fluttertoast.showToast(msg: "下单成功", gravity: ToastGravity.CENTER);
        }*/
        return true;
      }
    }

    if (netUpdateOrders.length > 0) {
      netUpdateOrders.forEach((netElement) {
        _activeOrders.forEach((actElement) {
          if (netElement.orderId == actElement.orderId) {
            actElement.market = netElement.market;
            actElement.side = netElement.side;
            actElement.price = netElement.price;
            actElement.amount = netElement.amount;
            actElement.ctime = netElement.ctime;
            actElement.status = netElement.status;
            actElement.amountDeal = netElement.amountDeal;
            actElement.amountNoDeal = netElement.amountNoDeal;
          }
        });
      });
      return true;
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
        /*if (showToast) {
          Fluttertoast.showToast(
              msg: S.of(context).order_cancelled_success,
              gravity: ToastGravity.CENTER);
        }*/
        return true;
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
      /*if (showToast) {
        Fluttertoast.showToast(
            msg: S.of(context).order_completed, gravity: ToastGravity.CENTER);
      }*/
      return true;
    }
  }
  return false;
}
