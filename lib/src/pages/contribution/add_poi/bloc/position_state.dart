import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';

abstract class PositionState extends AllPageState {}

class InitialPositionState extends PositionState {
  @override
  List<Object> get props => [];
}

class AddPositionState extends PositionState {
  AddPositionState();
}

// category
//todo: bloc 纯function
//todo: state 对应 UI展示

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
class GetOpenCageLoadingState extends PositionState {}

class GetOpenCageState extends PositionState {
  Map<String, dynamic> openCageData;

  GetOpenCageState(this.openCageData);
}

// uploading poi
class StartPostPoiDataState extends PositionState {}

class LoadingPostPoiDataState extends PositionState {
  double progress;

  LoadingPostPoiDataState(this.progress);
}

class SuccessPostPoiDataState extends PositionState {}

class FailPostPoiDataState extends PositionState {
  final int code;

  FailPostPoiDataState(this.code);
}

// uploading poi v2
class PostPoiDataV2ResultFailState extends PositionState {
  final int code;
  PostPoiDataV2ResultFailState({this.code});
}

class PostPoiDataV2ResultSuccessState extends PositionState {}

class PostPoiDataV2LoadingState extends PositionState {}

// confirm - v1
class GetConfirmPoiDataLoadingState extends PositionState {
  GetConfirmPoiDataLoadingState();
}

class GetConfirmPoiDataResultSuccessState extends PositionState {
  UserContributionPoi confirmPoiItem;

  GetConfirmPoiDataResultSuccessState(this.confirmPoiItem);
}

class GetConfirmPoiDataResultFailState extends PositionState {}

class PostConfirmPoiDataLoadingState extends PositionState {}

class ConfirmPositionResultLoadingState extends PositionState {}

class ConfirmPositionResultState extends PositionState {
  bool confirmResult;
  String errorMsg;

  ConfirmPositionResultState(this.confirmResult, this.errorMsg);
}

class PostConfirmPoiDataResultFailState extends PositionState {}

class PostConfirmPoiDataResultSuccessState extends PositionState {}

// confirm - v2
class GetConfirmDataV2LoadingState extends PositionState {
  GetConfirmDataV2LoadingState();
}

class GetConfirmDataV2ResultSuccessState extends PositionState {
  UserContributionPois userContributionPois;

  GetConfirmDataV2ResultSuccessState(this.userContributionPois);
}

class UpdateConfirmPoiDataPageState extends PositionState {}

class PostConfirmPoiDataV2LoadingState extends PositionState {}

class GetConfirmDataV2ResultFailState extends PositionState {
  int code;
  String message;
  GetConfirmDataV2ResultFailState({this.code, this.message});
}

class PostConfirmPoiDataV2ResultFailState extends PositionState {
  int code;
  String message;
  PostConfirmPoiDataV2ResultFailState({this.code, this.message});
}

class PostConfirmPoiDataV2ResultSuccessState extends PositionState {
  List<String> confirmResult;
  PostConfirmPoiDataV2ResultSuccessState(this.confirmResult);
}

// uploading poi ncov
class StartPostPoiNcovDataState extends PositionState {}

class LoadingPostPoiNcovDataState extends PositionState {
  double progress;

  LoadingPostPoiNcovDataState(this.progress);
}

class SuccessPostPoiNcovDataState extends PositionState {}

class FailPostPoiNcovDataState extends PositionState {
  final int code;

  FailPostPoiNcovDataState(this.code);
}
