import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/consts.dart';

class AddPositionImagePage extends StatefulWidget {
  AddPositionImagePage();

  @override
  State<StatefulWidget> createState() {
    return _AddPositionImageState();
  }
}

class _AddPositionImageState extends State<AddPositionImagePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<String> _titleList = [
    S.of(Keys.rootKey.currentContext).store_name_clear_when_shooting,
    S.of(Keys.rootKey.currentContext).shooting_picture_adjacent_shops,
    S.of(Keys.rootKey.currentContext).photo_outdoor_indoor_high_quality,
    S.of(Keys.rootKey.currentContext).not_take_mobile_booths_unfixed_locations
  ];

  List<String> _subtitleList = [
    "",
    S.of(Keys.rootKey.currentContext).no_shops_nearby_surrounding_environment,
    "",
    "",
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {

    _titleList = [
      S.of(context).add_position_image_title_1,
      S.of(context).add_position_image_title_2,
      S.of(context).add_position_image_title_3,
      S.of(context).add_position_image_title_4
    ];

    _subtitleList = [
      "",
      S.of(context).add_position_image_subtitle_2,
      "",
      "",
    ];
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).shooting_specifications_title,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: _bodyView(),
    );
  }

  Widget _bodyView() {
    _tabController = TabController(length: 4, vsync: this);

    return Stack(
      children: <Widget>[
        Scaffold(
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _imagesView(index: 0),
              _imagesView(index: 1),
              _imagesView(index: 2),
              _imagesView(index: 3),
            ],
          ),
        ),
        _bottomView(),
      ],
    );
  }

  Widget _imagesView({int index = 0}) {
    List<Widget> widgets = [];
    widgets.add(_titleView(index: index));

    switch (index) {
      case 0:
        widgets.add(_imageView(title: S.of(context).examples, imageName: "add_position_default_out"));
        break;

      case 1:
        widgets.add(_imageView(title: S.of(context).examples, imageName: "add_position_default_kfc"));

        break;

      case 2:
        var contents = [
          _imageView(title: S.of(context).outdoor_example, imageName: "add_position_default_out"),
          _imageView(title: S.of(context).indoor_example, imageName: "add_position_default_in"),
        ];
        widgets.addAll(contents);
        break;

      case 3:
        var contents = [
          _imageView(title: S.of(context).example + "1", imageName: "add_position_default_forbid_1"),
          _imageView(title: S.of(context).example + "2", imageName: "add_position_default_forbid_2"),
        ];
        widgets.addAll(contents);

        break;
    }

    widgets.add(SizedBox(
      height: 80,
    ));

    return Container(
      color: Colors.white,
      child: ListView.separated(
          itemBuilder: (context, value) {
            return widgets[value];
          },
          separatorBuilder: (context, index) {
            return Container(
              height: 20,
            );
          },
          itemCount: widgets.length),
    );
  }

  Widget _titleView({int index = 0}) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: RichText(
              text: TextSpan(
                  text: "${index + 1}",
                  style: TextStyle(
                    color: HexColor("#CD941E"),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                        text: "/${_titleList.length}",
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ))
                  ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: RichText(
                text: TextSpan(
                    text: _titleList[index],
                    style: TextStyle(
                      color: HexColor("#333333"),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(
                          text: _subtitleList[index],
                          style: TextStyle(
                            color: HexColor("#999999"),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ))
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageView({String title = "", String imageName = ""}) {
    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: HexColor("#999999"),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(
                  'res/drawable/$imageName.png',
                  width: 275,
                  height: 176,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomView() {
    var lastIndex = _titleList.length - 1;
    return Positioned(
      bottom: 0.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _currentIndex = _tabController.index;

                    _currentIndex -= 1;
                    if (_currentIndex <= 0) {
                      _currentIndex = 0;
                    }

                    _tabController.index = _currentIndex;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'res/drawable/add_position_image_pre.png',
                      width: 14,
                      height: 14,
                      color: HexColor("#999999"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    S.of(context).swipe_left_and_right_title,
                    style: TextStyle(
                      color: HexColor("#999999"),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _currentIndex = _tabController.index;

                    _currentIndex += 1;

                    if (_currentIndex > lastIndex) {
                      _currentIndex = lastIndex;
                    }
                    _tabController.index = _currentIndex;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'res/drawable/add_position_image_next.png',
                      width: 14,
                      height: 14,
                      color: HexColor("#999999"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
