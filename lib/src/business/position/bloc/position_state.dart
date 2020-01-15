import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';

abstract class PositionState {
  const PositionState();
}

class InitialPositionState extends PositionState {
  @override
  List<Object> get props => [];
}

class AddPositionState extends PositionState {
  AddPositionState();
}

// category
class SelectCategoryInitState extends PositionState {
  List<CategoryItem> categoryList;
  SelectCategoryInitState(this.categoryList);
}

class SelectCategoryLoadingState extends PositionState {
  bool isShowSearch;
  SelectCategoryLoadingState({this.isShowSearch = true});
}

class SelectCategoryResultState extends PositionState {
  List<CategoryItem> categoryList;
  SelectCategoryResultState({this.categoryList});
}

class SelectCategoryClearState extends PositionState {
  SelectCategoryClearState();
}

// get
class GetOpenCageState extends PositionState {
  Map<String, dynamic> openCageData;

  GetOpenCageState(this.openCageData);
}

// uploading
class StartPostPoiDataState extends PositionState {
}

class LoadingPostPoiDataState extends PositionState {
  double progress;
  LoadingPostPoiDataState(this.progress);
}

class SuccessPostPoiDataState extends PositionState {
}

class FailPostPoiDataState extends PositionState {

}

// confirm
class ConfirmPositionLoadingState extends PositionState {
  ConfirmPositionLoadingState();
}

class ConfirmPositionPageState extends PositionState {
  ConfirmPoiItem confirmPoiItem;
  ConfirmPositionPageState(this.confirmPoiItem);
}

class ConfirmPositionResultLoadingState extends PositionState {

}

class ConfirmPositionResultState extends PositionState {
  bool confirmResult;
  String errorMsg;
  ConfirmPositionResultState(this.confirmResult,this.errorMsg);
}