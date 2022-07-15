import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:utilx/utils.dart';
import '../utils/exports.dart';

const Logger _logger = Logger('icon');
const int defaultImageSize = 1000;
const int overlayContentSize = 200;

const List<TwinTuple<int, String>> androidIconSizes = <TwinTuple<int, String>>[
  TwinTuple<int, String>(defaultImageSize ~/ 4, 'mdpi'),
  TwinTuple<int, String>(defaultImageSize ~/ 3, 'hdpi'),
  TwinTuple<int, String>(defaultImageSize ~/ 2, 'xhdpi'),
  TwinTuple<int, String>(defaultImageSize ~/ 1.5, 'xxhdpi'),
  TwinTuple<int, String>(defaultImageSize ~/ 1, 'xxxhdpi'),
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

  final Image iconImage = drawImage(
    overlayImage,
    copyCrop(
      backgroundImage,
      0,
      overlayContentSize ~/ 2,
      defaultImageSize,
      defaultImageSize - overlayContentSize,
    ),
  );

  for (final TwinTuple<int, String> x in androidIconSizes) {
    final String iconPath = getAndroidIconPath(x.last);
    final File iconFile = File(iconPath);
    final List<int> icon = encodeNamedImage(
      copyResizeCropSquare(iconImage, x.first),
      path.basename(iconFile.path),
    )!;
    await iconFile.writeAsBytes(icon);
    _logger.info('Generated $iconPath (${x.last})');
  }
}
