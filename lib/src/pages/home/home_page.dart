import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/home/home_panel.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_dialog_page.dart';
import '../../widget/draggable_scrollable_sheet.dart' as myWidget;
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  Function function;
  bool homePageFirst;

  HomePage(this.homePageFirst, this.function, {Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends BaseState<HomePage> {
  List<RpShareSendEntity> _shareLatestList = [];
  final RPApi _rpApi = RPApi();

  String get _walletAddress =>
      WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  @override
  void onCreated() async {
    await Future.delayed(Duration(milliseconds: 333));
    BlocProvider.of<UpdateBloc>(context).add(CheckUpdate(lang: Localizations.localeOf(context).languageCode));

    getShareLatestList();

    super.onCreated();
  }

  void getShareLatestList() async {
    if (_walletAddress.isEmpty) {
      return;
    }
    _shareLatestList = await _rpApi.getShareLatestList(_walletAddress);
    if (mounted && _shareLatestList.isNotEmpty) {
      setState(() {});
    }
  }

  _rpShareBroadcastView() {
    if (_shareLatestList.isEmpty) {
      return Container();
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: HexColor('#FFFFFFFF'),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: HexColor('#000000').withOpacity(0.16),
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: Image.asset(
                    'res/drawable/rp_share_broadcast.png',
                    width: 14,
                    height: 16,
                  ),
                ),
                Expanded(
                  child: CarouselSlider(
                      items: _shareLatestList.map(
                        (model) {
                          var name = '${model?.owner ?? '--'}：';
                          var greeting = ((model?.greeting ?? '')?.isNotEmpty ?? false) ? model.greeting : '恭喜发财，大吉大利！';

                          var location = model?.location ?? '';
                          var isLocation = (model.rpType == RpShareType.location) && (location.isNotEmpty);

                          return InkWell(
                            onTap: () async {
                              if (isLocation) {
                                var mapSceneState = Keys.mapContainerKey.currentState as MapContainerState;
                                MapboxMapController mapboxMapController = mapSceneState.mapboxMapController;
                                LatLng latLng = LatLng(model.lat, model.lng);
                                mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLngZoom(latLng, 15), 700);
                              }

                              // await Future.delayed(Duration(milliseconds: 1600));
                              // showShareRpOpenDialog(context,id: model.id);
                            },
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      /*
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(width: 2, color: Colors.transparent),
                                              image: DecorationImage(
                                                //rp_share_broadcast_icon
                                                image: AssetImage("res/drawable/app_invite_default_icon.png"),
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      ),
                                      */
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: HexColor('#333333'),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          greeting,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: HexColor('#E8B000'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLocation)
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Image.asset(
                                            "res/drawable/rp_share_location_tag.png",
                                            width: 10,
                                            height: 14,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            location,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: HexColor('#999999'),
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      options: CarouselOptions(
                        aspectRatio: 8,
                        initialPage: 0,
                        viewportFraction: 1,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 5),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        scrollDirection: Axis.vertical,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.function();
    return myWidget.DraggableScrollableActuator(
      child: BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
        listener: (context, state) {
          if (state is DefaultScaffoldMapState) {
            myWidget.DraggableScrollableActuator.setMin(context);
          } else {
            myWidget.DraggableScrollableActuator.setHide(context);
          }
        },
        child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                if (state is DefaultScaffoldMapState) _rpShareBroadcastView(),
                buildMainSheetPanel(context, constraints),
              ],
            );
          });
        }),
      ),
    );
  }

  Widget buildMainSheetPanel(context, boxConstraints) {
    double maxHeight = boxConstraints.biggest.height;
    double anchorSize = 0.5;
    double minChildSize = 88.0 / maxHeight;
    double initSize = widget.homePageFirst ? 0.5 : minChildSize;
    EdgeInsets mediaPadding = MediaQuery.of(context).padding;
    double maxChildSize = (maxHeight - mediaPadding.top) / maxHeight;
    //hack, why maxHeight == 0 for the first time of release???
    if (maxHeight == 0.0) {
      return Container();
    }
    return myWidget.DraggableScrollableSheet(
      key: Keys.homePanelKey,
      maxHeight: maxHeight,
      maxChildSize: maxChildSize,
      expand: true,
      minChildSize: minChildSize,
      anchorSize: anchorSize,
      initialChildSize: initSize,
      draggable: true,
      builder: (BuildContext ctx, ScrollController scrollController) {
        return HomePanel(scrollController: scrollController);
      },
    );
  }
}
