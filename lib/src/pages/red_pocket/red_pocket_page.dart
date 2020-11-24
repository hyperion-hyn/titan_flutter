import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';

class RedPocketPage extends StatefulWidget {
  RedPocketPage();

  @override
  State<StatefulWidget> createState() {
    return _RedPocketPageState();
  }
}

class _RedPocketPageState extends State<RedPocketPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '红包 HRC30',
        backgroundColor: Colors.grey[50],
      ),
      body: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: false,
          onLoadData: () async {
            _requestData();
          },
          onRefresh: () async {
            _requestData();
          },
          child: CustomScrollView(
            slivers: <Widget>[],
          )),
    );
  }

  _myRPInfo() {
    var level = '-';
    var rpBalance = '-';
    var rpToday = '-';
    var rpYesterday = '-';
    var rpMissed = '-';
  }

  _rpInfo() {
    var total = '100W RP';
  }

  _rpPool() {
    var myStaking = '-';
    var totalStaking = '-';
    var rpYesterday = '-';
    var totalTransmission = '-';
  }

  _projectIntro() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Container(),
        ),
      ),
    );
  }

  _requestData() {
    _loadDataBloc.add(RefreshSuccessEvent());
  }
}
