import 'package:bloc/bloc.dart';

import 'bloc.dart';

abstract class SubmitBloc<Event extends SubmitEvent, State extends SubmitState> extends Bloc<Event, State> {}
