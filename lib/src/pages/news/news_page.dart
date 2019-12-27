import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewsPageState();
  }
}

class NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新闻'),
      ),
      body: Text('新闻'),
    );
  }
}
