import 'dart:io';
import 'dart:typed_data';

class ElevationProfileBytesDataProvider {

  Future<Uint8List> readBytesFromFile(String path) async {
    File file = File(path);
    Future<Uint8List> bytes = file.readAsBytes();
    return bytes;
  }
}