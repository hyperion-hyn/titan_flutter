import 'package:titan/src/business/position/model/category_item.dart';

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
  SelectCategoryInitState();
}

class SelectCategoryLoadingState extends PositionState {
  SelectCategoryLoadingState();
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
  ConfirmPositionPageState();
}

class ConfirmPositionResultState extends PositionState {
  ConfirmPositionResultState();
}