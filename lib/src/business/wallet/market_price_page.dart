import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/wallet/api/market_price_api.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/widget/load_data_widget.dart';

class MarketPricePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MarketPriceState();
  }
}

class _MarketPriceState extends State<MarketPricePage> {
  MarketPriceApi _marketPriceApi = MarketPriceApi();

  var marketPriceList = [];

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  var isLoading = true;

  @override
  void initState() {
    _getPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.white,
      appBar: AppBar(
//        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "HYN行情",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: LoadDataWidget(
        isLoading: isLoading,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildItem(marketPriceList[index]);
          },
          itemCount: marketPriceList.length,
        ),
      ),
    );
  }

  Widget _buildItem(MarketPriceVo marketPriceVo) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.only(bottom: 1),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewContainer(
                        initUrl: marketPriceVo.marketUrl,
                      )));
        },
        child: Row(
          children: <Widget>[
            FadeInImage.assetNetwork(
              placeholder: 'res/drawable/img_placeholder.jpg',
              image: marketPriceVo.iconUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 24,
            ),
            Text(
              marketPriceVo.marketName,
              style: TextStyle(color: Color(0xFF252525), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              "\$ ${DOUBLE_NUMBER_FORMAT.format(marketPriceVo.price)}",
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Future _getPrice() async {
    var marketPriceResponse = await _marketPriceApi.getHynMarketPriceResponse();
    isLoading = false;
    marketPriceList = marketPriceResponse.markets.map((_priceTemp) {
      return MarketPriceVo(
          iconUrl: _priceTemp.icon, marketName: _priceTemp.source, price: _priceTemp.price, marketUrl: _priceTemp.url);
    }).toList();

    setState(() {});
  }
}

class MarketPriceVo {
  String iconUrl;
  String marketName;
  double price;
  String marketUrl;

  MarketPriceVo({@required this.iconUrl, @required this.marketName, @required this.price, @required this.marketUrl});
}
