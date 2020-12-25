import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';

class MeCheckInHistoryDetail extends StatefulWidget {
  final CheckInModelPoi detail;

  MeCheckInHistoryDetail(this.detail);

  @override
  State<StatefulWidget> createState() {
    return _MeCheckInHistoryDetailState();
  }
}

class _MeCheckInHistoryDetailState extends BaseState<MeCheckInHistoryDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).false_location_determination,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headerView(),
              _postPoiView(),
              _confirmView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    text: S.of(context).determine_cause,
                    style: TextStyle(
                      color: HexColor("#333333"),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                          text: S.of(context).you_incorrectly_verified_place_you_submitted,
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ))
                    ]),
              ),
            ],
          ),
        ),
        Container(
          color: HexColor("#F5F5F5"),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                  child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      S.of(context).false_data_toast,
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _postPoiView() {
    var poiCreatedAt = "";
    int poiCreatedAtValue = 0;
    if (widget.detail?.poiCreatedAt != null) {
      poiCreatedAtValue = widget.detail?.poiCreatedAt;
    }
    if (poiCreatedAtValue > 0) {
      poiCreatedAt = Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(poiCreatedAtValue * 1000));
    }



    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 30, bottom: 16),
          child: RichText(
            text: TextSpan(
                text: S.of(context).where_you_submit,
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: (widget?.detail?.name?.isNotEmpty??false) ? widget.detail.name : "",
                                style: TextStyle(color: HexColor('#333333'), fontSize: 16, fontWeight: FontWeight.w600),
                                children: [
                                  TextSpan(
                                    text: "    ${(widget?.detail?.category?.isNotEmpty??false) ? widget.detail.category : ""}",
                                    style: TextStyle(
                                        color: HexColor('#333333'), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ]),
                          ),
                        ),
                        Text(
                          poiCreatedAt,
                          style: TextStyle(color: HexColor('#999999'), fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/check_in_location.png",
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            (widget?.detail?.address??false)?widget.detail.address:'',
                            style: TextStyle(color: HexColor('#999999'), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            //maxLines: 2,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: _itemHeight(),
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 15,
              childAspectRatio: (109.0 / 78.0),
            ),
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    ImagePickers.previewImages(widget.detail.originalImgs, index);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'res/drawable/img_placeholder.jpg',
                      image: widget.detail.originalImgs[index],
                      fit: BoxFit.cover,
                      width: 109,
                      height: 78,
                    ),
                  ));
            },
            itemCount: widget?.detail?.originalImgs?.length ?? 0,
          ),
        ),
      ],
    );
  }

  Widget _confirmView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 8),
          child: RichText(
            text: TextSpan(
                text: S.of(context).wrong_check_record,
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            //color: Colors.white,
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, value) {
                  return _detailItem(value);
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 4,
                  );
                },
                itemCount: widget?.detail?.detail?.length??0),
          ),
        ),
      ],
    );
  }

  Widget _detailItem(int index) {
    var model = widget.detail.detail[index];
    var createAt = Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000));

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: HexColor("#F5F5F5")),
      constraints: BoxConstraints.expand(height: _itemHeight() * 1.6),
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: S.of(context).determine_whether_picture_is_a_real_picture,
                        style: TextStyle(color: HexColor('#333333'), fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  Text(
                    createAt,
                    style: TextStyle(color: HexColor('#999999'), fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                  onTap: () {
                    ImagePickers.previewImages([widget.detail.image], 0);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'res/drawable/img_placeholder.jpg',
                      image: model.image,
                      fit: BoxFit.cover,
                      width: 109,
                      height: 78,
                    ),
                  )),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                    text: S.of(context).your_answer,
                    style: TextStyle(color: HexColor('#333333'), fontSize: 12, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(
                        text: "以上图片${model.answer ? " ${S.of(context).isolation_yes} " : " ${S.of(context).isolation_no} "}"+ S.of(context).poi_real_picture,
                        style: TextStyle(color: HexColor('#333333'), fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: S.of(context).wrong_answer,
                        style: TextStyle(color: HexColor('#D81E06'), fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _itemHeight() {
    var size = MediaQuery.of(context).size;
    var itemWidth = (size.width - 16 * 2.0 - 15 * 2.0) / 3.0;
    var childAspectRatio = (105.0 / 74.0);
    var itemHeight = itemWidth / childAspectRatio;
    var inItemCount = widget.detail?.originalImgs?.length ?? 0;
    double inContainerHeight = 16 + (16 + itemHeight) * ((inItemCount / 3).ceil());
    return inContainerHeight;
  }
}
