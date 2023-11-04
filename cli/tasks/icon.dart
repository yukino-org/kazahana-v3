import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import '../utils/exports.dart';

const Logger _logger = Logger('icon');
const int defaultImageSize = 1000;
const int overlayContentSize = 250;

const List<(int, String)> androidIconSizes = <(int, String)>[
  (defaultImageSize ~/ 1, 'mdpi'),
  (defaultImageSize ~/ 1.5, 'hdpi'),
  (defaultImageSize ~/ 2, 'xhdpi'),
  (defaultImageSize ~/ 3, 'xxhdpi'),
  (defaultImageSize ~/ 4, 'xxxhdpi'),
];

String getAndroidIconPath(final String code) => path.join(
      Paths.rootDir,
      'android/app/src/main/res/mipmap-$code/ic_launcher.png',
    );

Future<void> main() async {
  final String backgroundImagePath =
      path.join(Paths.iconsDir, 'background.png');
  final String overlayImagePath = path.join(Paths.iconsDir, 'overlay.png');
  _logger.info('Background Image Path: $backgroundImagePath');
  _logger.info('Overlay Image Path: $overlayImagePath');

  final Uint8List backgroundImageBytes =
      await File(backgroundImagePath).readAsBytes();
  final Uint8List overlayImageBytes =
      await File(overlayImagePath).readAsBytes();

  final Image backgroundImage = decodePng(backgroundImageBytes)!;
  final Image overlayImage = decodePng(overlayImageBytes)!;

  final Image iconImage = compositeImage(
    overlayImage,
    copyCrop(
      backgroundImage,
      x: 0,
      y: overlayContentSize ~/ 2,
      width: defaultImageSize,
      height: defaultImageSize - overlayContentSize,
    ),
  );

  for (final (int size, String code) in androidIconSizes) {
    final String iconPath = getAndroidIconPath(code);
    final File iconFile = File(iconPath);
    final List<int> icon = encodeNamedImage(
      path.basename(iconFile.path),
      copyResizeCropSquare(iconImage, size: size),
    )!;
    await iconFile.writeAsBytes(icon);
    _logger.info('Generated $iconPath ($code)');
  }
}
