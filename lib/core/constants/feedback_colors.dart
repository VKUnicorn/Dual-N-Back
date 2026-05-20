import 'package:flutter/material.dart';

/// Colours used for the 500 ms button flash that signals the outcome of
/// a match decision during a running session. Driven by the per-event
/// toggles in the "Feedback" settings group.
class FeedbackColors {
  FeedbackColors._();

  /// Button background flash for a correct press (hit on a real match).
  static const Color correct = Color(0xFF97CD99);

  /// Button background flash for an incorrect press (false alarm).
  static const Color incorrect = Color(0xFFE2807D);

  /// Button background flash for a missed match (signal present, no press).
  static const Color missed = Color(0xFFE8C069);
}
