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

class SelectCategorySelectedState extends PositionState {
  SelectCategorySelectedState();
}

class SelectTimeSelectedState extends PositionState {
  SelectTimeSelectedState();
}

class SelectImageSelectedState extends PositionState {
  SelectImageSelectedState();
}

class GetOpenCageState extends PositionState {
  GetOpenCageState();
}

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