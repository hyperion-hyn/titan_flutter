import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/Media.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/business/position/model/business_time.dart';
import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';
import 'package:titan/src/global.dart';
import './bloc.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionApi _positionApi = PositionApi();

  @override
  PositionState get initialState => InitialPositionState();

  CategoryItem categoryItem;

  String timeText;

  List<Media> listImagePaths = List();
  final int listImagePathsMaxLength = 9;

  LatLng userPosition;

  Map<String, dynamic> openCageData;

  PoiCollector _poiCollector;

  String poiName;
  String poiPhoneNum;
  String poiWebsite;
  String poiAddress;
  String poiHouseNum;
  String poiPostcode;

  @override
  Stream<PositionState> mapEventToState(
    PositionEvent event,
  ) async* {
    if (event is AddPositionEvent) {
      yield AddPositionState();
    } else if (event is SelectCategoryInitEvent) {
      yield SelectCategoryInitState();
    } else if (event is SelectCategoryLoadingEvent) {
      yield SelectCategoryLoadingState();
    } else if (event is SelectCategoryResultEvent) {
      var address = currentWalletVo.accountList[0].account.address;
      var categoryList =
          await _positionApi.getCategoryList(event.searchText, address);
      yield SelectCategoryResultState(categoryList: categoryList);
    } else if (event is SelectCategoryClearEvent) {
      yield SelectCategoryClearState();
    } else if (event is SelectCategorySelectedEvent) {
      categoryItem = event.categoryItem;
      yield SelectCategorySelectedState();
    } else if (event is SelectTimeSelectedEvent) {
      var timeItem = event.timeItem;
      if (timeItem is BusinessInfo) {
        String dayText = "";
        for (var item in timeItem.dayList) {
          if (!item.isCheck) continue;
          dayText += "${item.label}、";
        }
        timeText = timeItem.timeStr + " " + dayText;
      }
      yield SelectTimeSelectedState();
    } else if (event is SelectImageSelectedEvent) {
      _selectImages();
      yield SelectImageSelectedState();
    } else if (event is GetOpenCageEvent) {
      await _getOpenCageData();
      yield GetOpenCageState();
    } else if (event is StartPostPoiDataEvent) {
      _uploadPoiData();
      yield StartPostPoiDataState();
    } else if (event is LoadingPostPoiDataEvent) {
      yield LoadingPostPoiDataState(event.progress);
    } else if (event is SuccessPostPoiDataEvent) {
      yield StartPostPoiDataState();
    } else if (event is FailPostPoiDataEvent) {
      yield StartPostPoiDataState();
    } else if (event is ConfirmPositionLoadingEvent) {
      yield ConfirmPositionLoadingState();
    } else if (event is ConfirmPositionPageEvent) {
      yield ConfirmPositionPageState();
    } else if (event is ConfirmPositionResultEvent) {
      yield ConfirmPositionResultState();
    }
  }

  Future<void> _selectImages() async {
    var tempListImagePaths = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.image,
      selectCount: listImagePathsMaxLength - listImagePaths.length,
      showCamera: true,
      cropConfig: null,
      compressSize: 500,
      uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
    );
    listImagePaths.addAll(tempListImagePaths);
  }

  Future _getOpenCageData() async {
    var query = "${userPosition.latitude},${userPosition.longitude}";
    openCageData = await _positionApi.getOpenCageData(query, 'zh');
  }

  Future _uploadPoiData() async {
    print('[add] --> 存储中。。。');
    var _openCageData = openCageData;

    // 1.检测必须选项
    var _isEmptyOfCatogory = (categoryItem.title.length == 0 || categoryItem.title == "");
    var _isEmptyOfImages = (listImagePaths.length == 0);

    if (_isEmptyOfCatogory || _isEmptyOfImages) {
      Fluttertoast.showToast(msg: "类别、拍摄图片不能为空");
      return;
    }

    if (_openCageData == null) {
      print('[position_bloc]  ,OpenCageData 为空');
      //Fluttertoast.showToast(msg: "OpenCageData 为空");
      return;
    }

    var categoryId = categoryItem.id;
    var location = userPosition;
    var name = poiName;
    var country = _openCageData["country"] ?? "";
    var state = _openCageData["state"];
    var city = _openCageData["city"] + _openCageData["county"];
    var address1 = poiAddress;
    var address2 = "";
    var number = poiHouseNum ?? "";
    //var postalCode = _addressPostcodeController.text ?? "";
    var postalCode = _openCageData["postcode"];
    var workTime = timeText ?? "";
    var phone = poiPhoneNum ?? "";
    var website = poiWebsite ?? "";
    var country_code = _openCageData["country_code"] ?? "";
    _poiCollector = PoiCollector(categoryId, location, name, country_code, country, state, city, address1, address2,
        number, postalCode, workTime, phone, website);

    var address = currentWalletVo.accountList[0].account.address;
    bool isFinish = await _positionApi.postPoiCollector(listImagePaths, address, _poiCollector, (int count, int total) {
      double progress = count * 100.0 / total;
      print('[upload] total:${total}, count:${count}, progress:${progress}%');
      add(LoadingPostPoiDataEvent(progress));
    });

    if (isFinish) {
      add(SuccessPostPoiDataEvent());
    } else {
      add(FailPostPoiDataEvent());
    } 
  }


}
