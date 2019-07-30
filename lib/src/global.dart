import 'package:event_bus/event_bus.dart';
import 'package:logger/logger.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

var logger = Logger();


///some const
const safeAreaBottomPadding = 24.0;
const saveAreaTopPadding = 32.0;