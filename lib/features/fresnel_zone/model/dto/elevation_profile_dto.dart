class ElevationProfileDto {

  double distance = 0.0;
  int countOfPoints = 0;
  List<double> heights = [];

  ElevationProfileDto({required this.distance, required this.countOfPoints, required this.heights});
}