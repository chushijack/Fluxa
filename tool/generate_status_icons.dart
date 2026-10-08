import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'src/icons/ico.dart';

const sourceDir = 'assets_source/images/icon';
const pngOutputDir = 'assets/images/tray/unix';
const icoOutputDir = 'assets/images/tray/windows';
const macosOutputDir = 'assets/images/tray/macos';
const fluxaTrayRaster = '$sourceDir/fluxa-tray-status.png';
const fluxaLogoRaster = '$sourceDir/fluxa-logo.png';
const androidNotificationWhite =
    'android/service/src/main/res/drawable/fluxa_logo_notification_white.png';
const androidNotificationColor =
    'android/service/src/main/res/drawable/fluxa_logo_notification_color.png';
const androidNotificationSize = 256;
const androidLauncherForeground =
    'android/app/src/main/res/drawable/fluxa_launcher_foreground.png';
const androidBanner = 'android/app/src/main/res/mipmap-xhdpi/ic_banner.png';
const phoneLauncherMipmaps = {
  'android/app/src/main/res/mipmap-mdpi': 48,
  'android/app/src/main/res/mipmap-hdpi': 72,
  'android/app/src/main/res/mipmap-xhdpi': 96,
  'android/app/src/main/res/mipmap-xxhdpi': 144,
  'android/app/src/main/res/mipmap-xxxhdpi': 192,
};
const tvLauncherMipmaps = {
  'android/app/src/main/res/mipmap-television-mdpi': 80,
  'android/app/src/main/res/mipmap-television-hdpi': 120,
  'android/app/src/main/res/mipmap-television-xhdpi': 160,
  'android/app/src/main/res/mipmap-television-xxhdpi': 240,
  'android/app/src/main/res/mipmap-television-xxxhdpi': 320,
};
const macosAppIconDir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
const macosAppIconSizes = [16, 32, 64, 128, 256, 512, 1024];
const fluxaTrayStatusNames = ['status_1', 'status_2', 'status_3'];
const status4Source = '$sourceDir/status_4.svg';
const trayBaseSize = 18;
const trayScales = [1, 2, 3, 4];
const appIconPng = 'assets/images/icon.png';
const appIconAssetIco = 'assets/images/icon.ico';
const appIconOutput = 'windows/runner/resources/app_icon.ico';
const appIconRasterSize = 512;

Future<void> main() async {
  final rasterFile = File(fluxaTrayRaster);
  if (!rasterFile.existsSync()) {
    stderr.writeln('Missing Fluxa tray raster: ${rasterFile.path}');
    exitCode = 1;
    return;
  }

  final traySource = _squareTraySource(
    img.decodeImage(await rasterFile.readAsBytes())!,
  );

  await Directory(icoOutputDir).create(recursive: true);
  for (final name in fluxaTrayStatusNames) {
    await _writeTrayVariantsFromRaster(traySource, name, pngOutputDir);
    await _writeIcoFromRaster(
      traySource,
      File('$icoOutputDir/$name.ico'),
      sizes: trayIcoSizes,
    );
  }
  await _writeTrayVariantsFromRaster(traySource, 'status_1', macosOutputDir);

  final logoFile = File(fluxaLogoRaster);
  if (logoFile.existsSync()) {
    final logoSource = _squareTraySource(
      img.decodeImage(await logoFile.readAsBytes())!,
    );
    await _writeAndroidNotificationIcons(logoSource);
    await _writeAndroidLauncherIcons(logoSource);
    await _writeDesktopAppIcons(logoSource);
  } else {
    stderr.writeln('Missing Fluxa logo raster: ${logoFile.path}');
  }

  final rsvgConvert = await _findExecutable('rsvg-convert');
  if (rsvgConvert == null) {
    stderr.writeln(
      'rsvg-convert not found: skipped status_4 SVG tray icons only '
      '(install librsvg to regenerate them).',
    );
    return;
  }

  final tempDir = await Directory.systemTemp.createTemp('status_icons_');
  final renderer = _Renderer(rsvgConvert, tempDir);
  try {
    final status4 = File(status4Source);
    if (!status4.existsSync()) {
      stderr.writeln('Missing source SVG: ${status4.path}');
      exitCode = 1;
      return;
    }
    await _writeTrayVariants(renderer, status4, 'status_4', pngOutputDir);
    await _writeIco(
      renderer,
      status4,
      File('$icoOutputDir/status_4.ico'),
      sizes: trayIcoSizes,
    );
    await _writeTrayVariants(
      renderer,
      await renderer.monochrome(status4),
      'status_4',
      macosOutputDir,
    );
    final appIcon = await renderer.wrapRaster(File(appIconPng));
    await _writeIco(renderer, appIcon, File(appIconOutput));
  } finally {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

img.Image _squareTraySource(img.Image source) {
  final side = min(source.width, source.height);
  final x = (source.width - side) ~/ 2;
  final y = (source.height - side) ~/ 2;
  return img.copyCrop(source, x: x, y: y, width: side, height: side);
}

Uint8List _renderRasterSquare(img.Image source, int size) {
  final resized = img.copyResize(
    source,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodePng(resized));
}

Uint8List _encodeLauncherBytes(img.Image source, int size, String path) {
  final resized = img.copyResize(
    source,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );
  if (path.endsWith('.webp')) {
    return Uint8List.fromList(img.encodeWebP(resized, quality: 92));
  }
  return Uint8List.fromList(img.encodePng(resized));
}

Future<void> _writeTrayVariantsFromRaster(
  img.Image source,
  String name,
  String outputDir,
) async {
  for (final scale in trayScales) {
    final directory = scale == 1 ? outputDir : '$outputDir/$scale.0x';
    await Directory(directory).create(recursive: true);
    final output = File('$directory/$name.png');
    final size = trayBaseSize * scale;
    await output.writeAsBytes(_renderRasterSquare(source, size));
    stdout.writeln('Generated ${output.path}');
  }
}

Future<void> _writeDesktopAppIcons(img.Image source) async {
  final appPng = _renderRasterSquare(source, appIconRasterSize);
  final appFile = File(appIconPng);
  await appFile.parent.create(recursive: true);
  await appFile.writeAsBytes(appPng);
  stdout.writeln('Generated ${appFile.path}');
  for (final path in [appIconAssetIco, appIconOutput]) {
    await _writeIcoFromRaster(source, File(path), sizes: icoSizes);
  }
  final macDir = Directory(macosAppIconDir);
  await macDir.create(recursive: true);
  for (final size in macosAppIconSizes) {
    final output = File('${macDir.path}/app_icon_$size.png');
    await output.writeAsBytes(_renderRasterSquare(source, size));
    stdout.writeln('Generated ${output.path}');
  }
}

Future<void> _writeAndroidLauncherIcons(img.Image source) async {
  final foreground = _renderRasterSquare(source, 432);
  final foregroundFile = File(androidLauncherForeground);
  await foregroundFile.parent.create(recursive: true);
  await foregroundFile.writeAsBytes(foreground);
  stdout.writeln('Generated ${foregroundFile.path}');

  for (final MapEntry(key: directory, value: size)
      in phoneLauncherMipmaps.entries) {
    await _writeLauncherWebp(source, File('$directory/ic_launcher.webp'), size);
    await _writeLauncherWebp(
      source,
      File('$directory/ic_launcher_round.webp'),
      size,
    );
  }
  for (final MapEntry(key: directory, value: size)
      in tvLauncherMipmaps.entries) {
    await _writeLauncherWebp(source, File('$directory/ic_launcher.webp'), size);
  }
  await _writeAndroidBanner(source);
}

Future<void> _writeAndroidBanner(img.Image source) async {
  const width = 320;
  const height = 180;
  final canvas = img.Image(width: width, height: height, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(250, 250, 250, 255));
  final logoSide = (height * 0.72).round();
  final logo = img.copyResize(
    source,
    width: logoSide,
    height: logoSide,
    interpolation: img.Interpolation.average,
  );
  img.compositeImage(
    canvas,
    logo,
    dstX: (width - logoSide) ~/ 2,
    dstY: (height - logoSide) ~/ 2,
  );
  final bannerFile = File(androidBanner);
  await bannerFile.parent.create(recursive: true);
  await bannerFile.writeAsBytes(img.encodePng(canvas));
  stdout.writeln('Generated ${bannerFile.path}');
}

Future<void> _writeLauncherWebp(img.Image source, File output, int size) async {
  await output.parent.create(recursive: true);
  await output.writeAsBytes(_encodeLauncherBytes(source, size, output.path));
  stdout.writeln('Generated ${output.path}');
}

Future<void> _writeAndroidNotificationIcons(img.Image source) async {
  final resized = img.copyResize(
    source,
    width: androidNotificationSize,
    height: androidNotificationSize,
    interpolation: img.Interpolation.average,
  );
  final white = img.Image(
    width: androidNotificationSize,
    height: androidNotificationSize,
    numChannels: 4,
  );
  for (var y = 0; y < androidNotificationSize; y++) {
    for (var x = 0; x < androidNotificationSize; x++) {
      final pixel = resized.getPixel(x, y);
      final alpha = pixel.a / 255.0;
      if (alpha < 0.04) {
        continue;
      }
      final luminance =
          (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
      final outAlpha = (alpha * luminance * 255).round().clamp(0, 255);
      white.setPixelRgba(x, y, 255, 255, 255, outAlpha);
    }
  }
  final whiteFile = File(androidNotificationWhite);
  final colorFile = File(androidNotificationColor);
  await whiteFile.parent.create(recursive: true);
  await whiteFile.writeAsBytes(img.encodePng(white));
  await colorFile.writeAsBytes(img.encodePng(resized));
  stdout.writeln('Generated ${whiteFile.path}');
  stdout.writeln('Generated ${colorFile.path}');
}

Future<void> _writeIcoFromRaster(
  img.Image source,
  File output, {
  required List<int> sizes,
}) async {
  final entries = [
    for (final size in sizes)
      IcoEntry(size: size, png: _renderRasterSquare(source, size)),
  ];
  await output.parent.create(recursive: true);
  await output.writeAsBytes(buildIco(entries));
  stdout.writeln('Generated ${output.path}');
}

Future<void> _writeTrayVariants(
  _Renderer renderer,
  File source,
  String name,
  String outputDir,
) async {
  for (final scale in trayScales) {
    final directory = scale == 1 ? outputDir : '$outputDir/$scale.0x';
    await Directory(directory).create(recursive: true);
    final output = File('$directory/$name.png');
    await output.writeAsBytes(
      await renderer.render(source, trayBaseSize * scale),
    );
    stdout.writeln('Generated ${output.path}');
  }
}

Future<void> _writeIco(
  _Renderer renderer,
  File source,
  File output, {
  List<int> sizes = icoSizes,
}) async {
  final entries = [
    for (final size in sizes)
      IcoEntry(size: size, png: await renderer.render(source, size)),
  ];
  await output.parent.create(recursive: true);
  await output.writeAsBytes(buildIco(entries));
  stdout.writeln('Generated ${output.path}');
}

Future<String?> _findExecutable(String executable) async {
  final lookup = Platform.isWindows ? 'where' : 'which';
  final result = await Process.run(lookup, [executable]);
  if (result.exitCode != 0) {
    return null;
  }
  final line = (result.stdout as String).trim().split(RegExp(r'\r?\n')).first;
  return line.isEmpty ? null : line;
}

class _Renderer {
  _Renderer(this.rsvgConvert, this.tempDir);

  final String rsvgConvert;
  final Directory tempDir;
  int _sequence = 0;

  Future<Uint8List> render(File source, int size) async {
    final output = File('${tempDir.path}/${_sequence++}-$size.png');
    final result = await Process.run(rsvgConvert, [
      '-w',
      '$size',
      '-h',
      '$size',
      '-o',
      output.path,
      source.path,
    ]);
    if (result.exitCode != 0) {
      stderr
        ..writeln('Failed to render ${source.path} at ${size}px')
        ..writeln(result.stderr);
      exit(result.exitCode);
    }
    return output.readAsBytes();
  }

  Future<File> wrapRaster(File raster) async {
    final copy = await raster.copy('${tempDir.path}/${_basename(raster)}');
    final wrapper = File('${tempDir.path}/${_basename(raster)}.svg');
    await wrapper.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'width="256" height="256" viewBox="0 0 256 256">'
      '<image xlink:href="${_basename(copy)}" width="256" height="256"/>'
      '</svg>',
    );
    return wrapper;
  }

  Future<File> monochrome(File source) async {
    final copy = File('${tempDir.path}/mono-${_basename(source)}');
    await copy.writeAsString(
      (await source.readAsString()).replaceAllMapped(
        RegExp(r'\b(fill|stroke)="(?!none")[^"]*"'),
        (match) => '${match[1]}="#000000"',
      ),
    );
    return copy;
  }

  String _basename(File file) => file.uri.pathSegments.last;
}
