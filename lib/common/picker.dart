import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/fluxa/integration/import_capture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<PlatformFile?> pickerFile() async {
    return FilePicker.pickFile(initialDirectory: await appPath.downloadDirPath);
  }

  Future<Uri?> saveFile(String fileName, Uint8List bytes) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (!system.isAndroid && uri != null && uri.scheme == 'file') {
      final file = File(uri.toFilePath());
      await file.safeWriteAsBytes(bytes);
    }
    return uri;
  }

  Future<Uri?> saveFileWithPath(String fileName, String localPath) async {
    final localFile = File(localPath);
    if (!await localFile.exists()) {
      await localFile.create(recursive: true);
    }
    final bytes = await localFile.readAsBytes();
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    await localFile.safeDelete();
    return uri;
  }

  Future<ImportCaptureResult?> pickerImportCaptureFromQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    // Not through a throwaway MobileScannerController: disposing one clears
    // the platform scan window of a scanner page that is still open.
    final barcodeCapture = await MobileScannerPlatform.instance.analyzeImage(
      xFile.path,
      formats: const [BarcodeFormat.qrCode],
    );
    final result = resolveImportCaptureFromTexts(
      barcodeCapture?.barcodes.map((barcode) => barcode.rawValue) ?? const [],
    );
    if (result == null) {
      throw MessageException(currentAppLocalizations.pleaseUploadValidQrcode);
    }
    return result;
  }

  Future<String?> pickerConfigQRCode() async {
    final capture = await pickerImportCaptureFromQRCode();
    return switch (capture) {
      SubscriptionImportCapture(:final url) => url,
      _ => null,
    };
  }
}

extension PlatformFileExt on PlatformFile {
  Future<Uint8List> readBytes() {
    return readAsBytes();
  }
}

final picker = Picker();
