import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:meta/meta.dart';

/// One trial (one stimulus presentation) within a session.
///
/// `index` is 0-based. `isMatch[c]` is the ground-truth answer:
/// true if the value at this trial equals the value at trial `index - n`
/// for channel `c`. For trials with `index < n`, `isMatch` is always false
/// across all channels (no n-back reference exists yet).
@immutable
class Trial {
  const Trial({
    required this.index,
    required this.frame,
    required this.isMatch,
  });

  final int index;
  final StimulusFrame frame;
  final Map<ChannelType, bool> isMatch;

  bool isMatchOn(ChannelType channel) {
    final v = isMatch[channel];
    if (v == null) {
      throw ArgumentError('Channel $channel is not active in this trial.');
    }
    return v;
  }

  @override
  String toString() =>
      'Trial(index: $index, frame: $frame, isMatch: $isMatch)';
}
