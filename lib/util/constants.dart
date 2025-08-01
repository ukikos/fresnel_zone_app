class Constants {
  static bool isFullscreenSizeInitialized = false;
  static double fullscreenWidth = 0;
  static double fullscreenHeight = 0;
  
  static const double earthRadius = 6371302;

  static const double minFrequency = 30000000;
  static const double maxFrequency = 6000000000;
  static const double speedOfLight = 299792458;

  static const int countOfFresnelZonePoints = 1000;

  static const double maxFresnelZoneOverlapCoefficient = 0.4;

  // min_x, min_y, max_x, max_y
  static const List<double> canvasRangeOfValues = [0.02, 0.02, 0.98, 0.98];
}