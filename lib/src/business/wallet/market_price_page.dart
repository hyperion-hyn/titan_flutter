import 'package:flutter/material.dart';
import 'package:titan/src/consts/consts.dart';

class MarketPricePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MarketPriceState();
  }
}

class _MarketPriceState extends State<MarketPricePage> {
  var marketPriceList = [
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox",
        price: 0.9),
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox1",
        price: 0.8),
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox2",
        price: 0.7),
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox3",
        price: 0.6),
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox4",
        price: 0.7),
    MarketPriceVo(
        iconUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvuyezoVTDHfSBMjeBSqsXbxDmZKiw87GVMYlEUAutIyPSREbh",
        marketName: "bibox5",
        price: 0.8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
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
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Image.network(
            marketPriceVo.iconUrl,
            width: 48,
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
            "\$ ${Const.DOUBLE_NUMBER_FORMAT.format(marketPriceVo.price)}美元",
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class MarketPriceVo {
  String iconUrl;
  String marketName;
  double price;

  MarketPriceVo({@required this.iconUrl, @required this.marketName, @required this.price});
}
