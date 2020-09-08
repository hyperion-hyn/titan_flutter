import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/exchange_banner.dart';
import 'package:titan/src/pages/webview/webview.dart';

class ExchangeBannerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangeBannerWidgetState();
  }
}

class _ExchangeBannerWidgetState extends BaseState<ExchangeBannerWidget> {
  ExchangeApi _exchangeApi = ExchangeApi();
  List<ExchangeBanner> _activeBannerList = List();
  List<Widget> _bannerWidgetList = List();

  PageController _pageController = PageController(
    initialPage: 0,
  );

  Timer _timer;

  int _currentPage = 0;

  @override
  Future<void> onCreated() async {
    super.onCreated();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getActiveBannerList();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _activeBannerList.length) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeBannerList.isNotEmpty) {
      return Container(
        height: 45,
        color: HexColor('#0F1FB9C7'),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 8,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    'res/drawable/ic_exchange_banner_msg.png',
                    height: 15,
                    width: 14,
                  )),
              Expanded(
                child: PageView(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  children: _bannerWidgetList,
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  _getActiveBannerList() async {
    try {
      List<ExchangeBanner> banners = await _exchangeApi.getBannerList();
      banners.forEach((banner) {
        var _expired = int.parse(banner.expire);
        var _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (banner.onShow == '1' && _expired > _now) {
          _activeBannerList.add(banner);
          _bannerWidgetList.add(_bannerItem(banner));
        }
      });
      setState(() {});
    } catch (e) {}
  }

  _bannerItem(ExchangeBanner banner) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        child: Text(
          banner.html,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewContainer(
                        initUrl: banner.url,
                      )));
        },
      ),
    );
  }
}
