

abstract class ScaffoldMapState {
  const ScaffoldMapState();
}

class InitialScaffoldMapState extends ScaffoldMapState {
}


//-----------------
//  poi
//-----------------

class SearchingPoiState extends ScaffoldMapState {
}

class ShowPoiState extends ScaffoldMapState {
}

class SearchPoiFailState extends ScaffoldMapState {
}


//-----------------
//  search
//-----------------

/// searching pois
class SearchingPoiListState extends ScaffoldMapState {

}

class SearchPoiListSuccessState extends ScaffoldMapState {

}

class SearchPoiListFailState extends ScaffoldMapState {

}


//-----------------
//  route
//-----------------

class RoutingState extends ScaffoldMapState {

}

class RouteSuccessState extends ScaffoldMapState {

}

class RouteFailState extends ScaffoldMapState {

}


//-----------------
//  navigation
//-----------------

class NavigationState extends ScaffoldMapState {
}