abstract class ProgressMaskDialogEvent {
  const ProgressMaskDialogEvent();
}

class CloseDialogEvent extends ProgressMaskDialogEvent {}

class ShowDialogEvent extends ProgressMaskDialogEvent {}
