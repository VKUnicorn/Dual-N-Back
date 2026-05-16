import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:meta/meta.dart';

/// One of the four stimulus channels in N-back.
enum ChannelType {
  position,
  audio,
  color,
  shape;

  /// Number of distinct stimulus values for this channel.
  ///
  /// For [ChannelType.position] this is `gridSize² − 1`: the center cell is
  /// reserved for a fixation cross (Jaeggi 2008 — "eight different
  /// locations"), so the position channel never uses it.
  int get cardinality {
    switch (this) {
      case ChannelType.position:
        return NBackDefaults.gridSize * NBackDefaults.gridSize - 1;
      case ChannelType.audio:
        return NBackDefaults.audioLetters.length;
      case ChannelType.color:
        return NBackDefaults.colorPalette.length;
      case ChannelType.shape:
        return NBackDefaults.shapeCount;
    }
  }
}

/// Stimulus values across all active channels for a single trial.
@immutable
class StimulusFrame {
  const StimulusFrame(this.values);

  final Map<ChannelType, int> values;

  int operator [](ChannelType channel) {
    final v = values[channel];
    if (v == null) {
      throw ArgumentError('Channel $channel is not active in this frame.');
    }
    return v;
  }

  Iterable<ChannelType> get channels => values.keys;

  @override
  bool operator ==(Object other) {
    if (other is! StimulusFrame) return false;
    if (other.values.length != values.length) return false;
    for (final entry in values.entries) {
      if (other.values[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
        values.entries.map((e) => Object.hash(e.key, e.value)),
      );

  @override
  String toString() => 'StimulusFrame($values)';
}
