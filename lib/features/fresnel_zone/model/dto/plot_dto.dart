class PlotDto {

  List<List<double>> elevationProfileCoordinates;
  List<List<double>> seaLevelPointsCoordinates;
  List<List<double>> antennaCoordinates;
  List<List<double>> fresnelZoneCoordiantes;
  bool isFresnelZoneBlocked;
  bool isLineOfSightBlocked;

  PlotDto({
    required this.elevationProfileCoordinates,
    required this.seaLevelPointsCoordinates,
    required this.antennaCoordinates,
    required this.fresnelZoneCoordiantes,
    required this.isFresnelZoneBlocked,
    required this.isLineOfSightBlocked
  });
}