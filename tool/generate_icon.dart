// Generates a 1024×1024 placeholder app icon at assets/icon/icon.png.
//
// The icon mirrors what the in-game grid actually looks like: a 3×3 grid
// on an indigo background, the centre cell shows only a soft grey "+"
// fixation marker (no surrounding tile), eight outer cells are dim white,
// and one of them is highlighted in the game palette's violet to read as
// an active stimulus. Re-run this whenever the design changes:
//
//   dart run tool/generate_icon.dart
//
// After regenerating, run `dart run flutter_launcher_icons` to refresh
// the launcher icons.

import 'dart:io';

import 'package:image/image.dart';

const _size = 1024;
const _grid = 3;

// Centre of the 3×3 — reserved for the fixation cross.
const _centerRow = 1;
const _centerCol = 1;

// Which outer cell carries the "active stimulus" highlight. Top-right
// reads well next to a centred fixation cross.
const _highlightRow = 0;
const _highlightCol = 2;

void main() {
  final image = Image(width: _size, height: _size, numChannels: 4);

  // Background — neutral mid-grey; the indigo highlight cell and
  // dim-white outer cells both read clearly against it.
  fill(image, color: ColorRgba8(0x40, 0x40, 0x40, 0xFF));

  // Subtle inner card (kept for parity with the previous icon, in case
  // launcher masks crop the corners aggressively).
  const padding = 96;
  fillRect(
    image,
    x1: padding,
    y1: padding,
    x2: _size - padding - 1,
    y2: _size - padding - 1,
    color: ColorRgba8(0x40, 0x40, 0x40, 0xFF),
    radius: 160,
  );

  const cellGap = 32;
  const available = _size - padding * 2;
  const cellSize = (available - cellGap * (_grid - 1)) ~/ _grid;

  // 8 outer cells + 1 highlighted, centre stays empty (just the +).
  for (var r = 0; r < _grid; r++) {
    for (var c = 0; c < _grid; c++) {
      final isCenter = r == _centerRow && c == _centerCol;
      if (isCenter) continue;
      final x = padding + c * (cellSize + cellGap);
      final y = padding + r * (cellSize + cellGap);
      final isHighlighted = r == _highlightRow && c == _highlightCol;
      final color = isHighlighted
          // App theme primary — the indigo seed (#4F46E5) used across
          // the rest of the UI.
          ? ColorRgba8(0x4F, 0x46, 0xE5, 0xFF)
          // Dim white — reads as a soft grey on the indigo background.
          : ColorRgba8(0xFF, 0xFF, 0xFF, 0x33);
      fillRect(
        image,
        x1: x,
        y1: y,
        x2: x + cellSize - 1,
        y2: y + cellSize - 1,
        color: color,
        radius: 56,
      );
    }
  }

  _drawFixationCross(image, padding, cellSize, cellGap);

  final outDir = Directory('assets/icon');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }
  final outFile = File('assets/icon/icon.png');
  final bytes = encodePng(image);
  outFile.writeAsBytesSync(bytes);
  stdout.writeln('Wrote ${outFile.path} (${bytes.length} bytes)');
}

/// Renders a soft grey "+" in the centre cell — mirrors the fixation
/// marker drawn by `NBackGrid` in-game (white @ ~35% alpha). The cross
/// has no surrounding tile so the centre reads as visually open.
void _drawFixationCross(
  Image image,
  int padding,
  int cellSize,
  int cellGap,
) {
  final cellX = padding + _centerCol * (cellSize + cellGap);
  final cellY = padding + _centerRow * (cellSize + cellGap);
  // Cross arm length & thickness as fractions of the cell. The arm
  // length matches `kFixationSizeFactor` (0.8) used in-game; thickness
  // is tuned to read at small launcher sizes without looking like a
  // plus-sign.
  final armLength = (cellSize * 0.78).round();
  final thickness = (cellSize * 0.12).round();
  final centerX = cellX + cellSize ~/ 2;
  final centerY = cellY + cellSize ~/ 2;
  final color = ColorRgba8(0xFF, 0xFF, 0xFF, 0x59); // ≈ 35% alpha

  // Horizontal arm.
  fillRect(
    image,
    x1: centerX - armLength ~/ 2,
    y1: centerY - thickness ~/ 2,
    x2: centerX + armLength ~/ 2,
    y2: centerY + thickness ~/ 2,
    color: color,
    radius: thickness ~/ 2,
  );
  // Vertical arm.
  fillRect(
    image,
    x1: centerX - thickness ~/ 2,
    y1: centerY - armLength ~/ 2,
    x2: centerX + thickness ~/ 2,
    y2: centerY + armLength ~/ 2,
    color: color,
    radius: thickness ~/ 2,
  );
}
