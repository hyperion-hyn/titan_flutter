import 'package:bloc/bloc.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/progress_mask_dialog_event.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/progress_mask_dialog_state.dart';

class ProgressMaskDialogBloc extends Bloc<ProgressMaskDialogEvent, ProgressMaskDialogState> {
  ProgressMaskDialogBloc();

  @override
  Stream<ProgressMaskDialogState> mapEventToState(ProgressMaskDialogEvent event) async* {
    if (event is CloseDialogEvent) {
      yield CloseState();
    }
    if (event is ShowDialogEvent) {
      yield ShowingState();
    }
  }

  @override
  ProgressMaskDialogState get initialState => ShowingState();
}
