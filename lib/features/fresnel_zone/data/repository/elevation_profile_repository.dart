import 'dart:typed_data';

import 'package:fresnel_zone_app/features/fresnel_zone/data/data_provider/elevation_profile_bytes_data_provider.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/elevation_profile_dto.dart';

class ElevationProfileRepository {

  final ElevationProfileBytesDataProvider _elevationProfileBytesDataProvider = ElevationProfileBytesDataProvider();

  Future<ElevationProfileDto> getElevationProfileFromFile(String path) async {
    Uint8List bytes = await getElevationProfileBytesFromFile(path);
    return _parseBytesElevationProfile(bytes);
  }

  Future<Uint8List> getElevationProfileBytesFromFile(String path) async {
    return _elevationProfileBytesDataProvider.readBytesFromFile(path);
  }

  ElevationProfileDto _parseBytesElevationProfile(Uint8List bytes) {
    ByteData byteData = ByteData.sublistView(bytes);
    double distance = byteData.getFloat64(0, Endian.big);
    int countOfPoints = byteData.getUint32(8, Endian.big);

    List<double> heights = [];

    for (var i = 0; i < countOfPoints; i++) {
      heights.add(byteData.getUint32(12 + 4 * i, Endian.big).toDouble());
    }

    return ElevationProfileDto(distance: distance, countOfPoints: countOfPoints, heights: heights);
  }
}