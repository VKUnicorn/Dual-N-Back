import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

/// Current system media-stream volume, range `0.0..1.0`, kept live via
/// the native broadcast receiver in `flutter_volume_controller`.
///
/// The plugin tracks only one global listener, so this provider owns
/// the single subscription for the whole app — callers should
/// `ref.watch(mediaVolumeProvider)` directly rather than calling
/// `FlutterVolumeController.addListener` themselves.
///
/// Emits the current value on subscription (`emitOnStart: true`) plus
/// every subsequent change. Errors from the native side propagate as
/// `AsyncError`; consumers can fall back to "warning hidden" so a
/// silent failure doesn't block the start screen.
final mediaVolumeProvider = StreamProvider<double>((ref) {
  final controller = StreamController<double>();
  final sub = FlutterVolumeController.addListener(controller.add);
  ref.onDispose(() {
    unawaited(sub.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});
