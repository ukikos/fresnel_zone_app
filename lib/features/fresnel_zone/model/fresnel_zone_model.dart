import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/data/repository/elevation_profile_repository.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/elevation_profile_dto.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/plot_dto.dart';
import 'package:fresnel_zone_app/util/constants.dart';

class FresnelZoneModel extends ChangeNotifier {

  final ElevationProfileRepository _elevationProfileRepository = ElevationProfileRepository();

  bool isCalculatiing = false;

  // Input data

  /// Path to the file with elevation profile
  String? filePath;

  /// Height of the first antenna
  double? height_1;

  /// Height of the second antenna
  double? height_2;

  /// Signal frequency
  double? frequency;


  // Elevation profile

  /// Distance between extreme points of the elevation profile (at sea level)
  double? _distance;

  /// Count of elevation profile points
  int? _countOfElevationProfilePoints;

  /// Heights of elevation profile points
  late List<double> _elevationProfileHeights;


  // Model (polar)

  /// Angular distance between extreme points of the elevation profile
  late double _totalAngularDistance;
  
  /// Coordinates of elevation profile points in polar coordinate system (r, phi)
  late List<List<double>> _elevationProfileCoordinatesPolar;

  /// Coordinates of sea level points in polar coordinate system (r, phi)
  late List<List<double>> _seaLevelCoordinatesPolar;

  /// Antenna points coordinates in polar coordinate system (r, phi)
  late List<List<double>> _antennaCoordinatesPolar;


  // Model (cartesian)

  /// Coordinates of elevation profile points in cartesian coordinate system (x, y)
  late List<List<double>> _elevationProfileCoordinates;

  /// Coordinates of sea level points in cartesian coordinate system (x, y)
  late List<List<double>> _seaLevelCoordinates;

  /// Extreme points of the elevation profile at sea level
  late List<List<double>> _seaLevelExtremePointsCoordinates;
  
  /// Antenna points coordinates in cartesian coordinate system (x, y)
  late List<List<double>> _antennaCoordinates;

  /// Fresnel zone points coordinates points coordinates in cartesian coordinate system (x, y)
  late List<List<double>> _fresnelZoneCoordiantes;


  // Hypotheses

  /// Fresnel zone blocking state
  late bool _isFresnelZoneBlocked;

  /// Line of sight blocking state
  late bool _isLineOfSightBlocked;


  void setFilePath(String path) {
    filePath ??= path;
    if (filePath!.compareTo(path) != 0) {
      filePath = path;
    }
    if (isModelInitialized()) {
      calculateModel();
    }
  }

  void setHeight1(double height) {
    if (height < 0.0 || height > 10000.0) {
      return;
    }
    height_1 ??= height;
    if (height_1!.compareTo(height) != 0) {
      height_1 = height;
    }
    if (isModelInitialized()) {
      calculateModel();
    }
  }

  void setHeight2(double height) {
    if (height < 0.0 || height > 10000.0) {
      return;
    }
    height_2 ??= height;
    if (height_2!.compareTo(height) != 0) {
      height_2 = height;
    }
    if (isModelInitialized()) {
      calculateModel();
    }
  }

  void setFrequency(double frequency) {
    if (frequency < Constants.minFrequency || frequency > Constants.maxFrequency) {
      return;
    }
    this.frequency ??= frequency;
    if (this.frequency!.compareTo(frequency) != 0) {
      this.frequency = frequency;
    }
    if (isModelInitialized()) {
      calculateModel();
    }
  }

  double? getDistance() {
    return _distance;
  }

  int? getCountOfPoints() {
    return _countOfElevationProfilePoints;
  }

  bool isModelInitialized() {
    return [filePath, height_1, height_2, frequency].contains(null) ? false : true;
  }

  void calculateModel() async {
    isCalculatiing = true;
    // Get elevation profile
    ElevationProfileDto elevationProfileDto = await _elevationProfileRepository.getElevationProfileFromFile(filePath!);
    _distance = elevationProfileDto.distance;
    _countOfElevationProfilePoints = elevationProfileDto.countOfPoints;
    _elevationProfileHeights = elevationProfileDto.heights;

    // Calculate angles
    _totalAngularDistance = _distance! / Constants.earthRadius;
    List<double> angularRange = [(pi / 2) + _totalAngularDistance / 2, (pi / 2) - _totalAngularDistance / 2];
    double angularStep = (angularRange[1] - angularRange[0]) / (_countOfElevationProfilePoints! - 1);

    // Calculate profile polar coordinates
    _elevationProfileCoordinatesPolar = [];
    double currAngle = angularRange[0];
    for (int i = 0; i < _countOfElevationProfilePoints!; i++) {
      List<double> currPoint = List.filled(2, 0);
      currPoint[0] = Constants.earthRadius + _elevationProfileHeights[i];
      currPoint[1] = currAngle;
      _elevationProfileCoordinatesPolar.add(currPoint);
      currAngle = currAngle + angularStep;
    }

    // Calculate sea level polar coordinates
    _seaLevelCoordinatesPolar = [];
    currAngle = angularRange[0];
    for (int i = 0; i < _countOfElevationProfilePoints!; i++) {
      List<double> currPoint = List.filled(2, 0);
      currPoint[0] = Constants.earthRadius;
      currPoint[1] = currAngle;
      _seaLevelCoordinatesPolar.add(currPoint);
      currAngle = currAngle + angularStep;
    }
    
    // Calculate antenna polar coordinates
    _antennaCoordinatesPolar = [];
    _antennaCoordinatesPolar.add([Constants.earthRadius + _elevationProfileHeights.first + height_1!, angularRange.first]);
    _antennaCoordinatesPolar.add([Constants.earthRadius + _elevationProfileHeights.last + height_2!, angularRange.last]);


    // Cartesian
    // Calculate profile cartesian coordinates
    _elevationProfileCoordinates = [];
    for (int i = 0; i < _countOfElevationProfilePoints!; i++) {
      List<double> currPoint = List.filled(2, 0);
      double r = _elevationProfileCoordinatesPolar[i][0];
      double phi = _elevationProfileCoordinatesPolar[i][1];
      currPoint[0] = r * cos(phi);
      currPoint[1] = r * sin(phi);
      _elevationProfileCoordinates.add(currPoint);
    }

    // Calculate sea level coordinates (from left to right)
    _seaLevelCoordinates = [];
    for (int i = 0; i < _countOfElevationProfilePoints!; i++) {
      List<double> currPoint = List.filled(2, 0);
      double r = _seaLevelCoordinatesPolar[i][0];
      double phi = _seaLevelCoordinatesPolar[i][1];
      currPoint[0] = r * cos(phi);
      currPoint[1] = r * sin(phi);
      _seaLevelCoordinates.add(currPoint);
    }

    // Calculate sea level extreme points cartesian coordinates
    _seaLevelExtremePointsCoordinates = [];
    _seaLevelExtremePointsCoordinates.add([
      Constants.earthRadius * cos(angularRange.first),
      Constants.earthRadius * sin(angularRange.first)
    ]);
    _seaLevelExtremePointsCoordinates.add([
      Constants.earthRadius * cos(angularRange.last),
      Constants.earthRadius * sin(angularRange.last)
    ]);

    // Calculate antenna points cartesian coordinates
    _antennaCoordinates = [];
    _antennaCoordinates.add([
      _antennaCoordinatesPolar[0][0] * cos(_antennaCoordinatesPolar[0][1]),
      _antennaCoordinatesPolar[0][0] * sin(_antennaCoordinatesPolar[0][1])
    ]);
    _antennaCoordinates.add([
      _antennaCoordinatesPolar[1][0] * cos(_antennaCoordinatesPolar[1][1]),
      _antennaCoordinatesPolar[1][0] * sin(_antennaCoordinatesPolar[1][1])
    ]);

    // Calculate fresnel zone cartesian coordinates (visual)
    // Total (2 * Constants.countOfFresnelZonePoints - 2) points
    _fresnelZoneCoordiantes = [];
    int countOfFresnelZonePoints = Constants.countOfFresnelZonePoints;
    double lineOfSightStepX = (_antennaCoordinates[1][0] - _antennaCoordinates[0][0]) / (countOfFresnelZonePoints - 1);
    double lineOfSightStepY = (_antennaCoordinates[1][1] - _antennaCoordinates[0][1]) / (countOfFresnelZonePoints - 1);

    double antenna1X = _antennaCoordinates[0][0];
    double antenna1Y = _antennaCoordinates[0][1];
    double antenna2X = _antennaCoordinates[1][0];
    double antenna2Y = _antennaCoordinates[1][1];

    // From the first (left) point clockwise
    _fresnelZoneCoordiantes.add([antenna1X, antenna1Y]);
    for (int i = 1; i < countOfFresnelZonePoints - 1; i++) {
      double currPointX = antenna1X + i * lineOfSightStepX;
      double currPointY = antenna1Y + i * lineOfSightStepY;
      double d1 = _distanceBetweenTwoPoints(currPointX, currPointY, antenna1X, antenna1Y);
      double d2 = _distanceBetweenTwoPoints(currPointX, currPointY, antenna2X, antenna2Y);
      double radiusOfFZ = _radiusOfFirstFresnelZone(d1, d2, frequency!);
      List<double> currFresnelZonePoint = _pointBySegmentAndUpperPerpendicularLength(currPointX, currPointY, antenna1X, antenna1Y, radiusOfFZ);
      _fresnelZoneCoordiantes.add([currFresnelZonePoint[0], currFresnelZonePoint[1]]);
    }

    _fresnelZoneCoordiantes.add([antenna2X, antenna2Y]);
    for (int i = 1; i < countOfFresnelZonePoints - 1; i++) {
      double currPointX = antenna2X - i * lineOfSightStepX;
      double currPointY = antenna2Y - i * lineOfSightStepY;
      double d1 = _distanceBetweenTwoPoints(currPointX, currPointY, antenna2X, antenna2Y);
      double d2 = _distanceBetweenTwoPoints(currPointX, currPointY, antenna1X, antenna1Y);
      double radiusOfFZ = _radiusOfFirstFresnelZone(d1, d2, frequency!);
      List<double> currFresnelZonePoint = _pointBySegmentAndLowerPerpendicularLength(currPointX, currPointY, antenna2X, antenna2Y, radiusOfFZ);
      _fresnelZoneCoordiantes.add([currFresnelZonePoint[0], currFresnelZonePoint[1]]);
    }

    // Calculate hypotheses
    _isFresnelZoneBlocked = false;
    _isLineOfSightBlocked = false;

    for (int i = 0; i < _countOfElevationProfilePoints!; i++) {
      double elevProfilePointX = _elevationProfileCoordinates[i][0];
      double elevProfilePointY = _elevationProfileCoordinates[i][1];


      List<double> intersectionPoint = _intersectionPointOfLineAndPerpendecular(
        antenna1X, antenna1Y,
        antenna2X, antenna2Y,
        elevProfilePointX, elevProfilePointY
      );

      if (intersectionPoint[1] < elevProfilePointY) {
        _isFresnelZoneBlocked = true;
        _isLineOfSightBlocked = true;
        break;
      }

      double distanceFromElevProfilePointToLineOfSight = _distanceBetweenTwoPoints(
        elevProfilePointX, elevProfilePointY,
        intersectionPoint[0], intersectionPoint[1]
      );

      double d1 = _distanceBetweenTwoPoints(intersectionPoint[0], intersectionPoint[1], antenna1X, antenna1Y);
      double d2 = _distanceBetweenTwoPoints(intersectionPoint[0], intersectionPoint[1], antenna2X, antenna2Y);

      double radiusOfFZ = _radiusOfFirstFresnelZone(d1, d2, frequency!);

      double overlapCoefficient = 1 - (distanceFromElevProfilePointToLineOfSight / radiusOfFZ);

      if (overlapCoefficient > Constants.maxFresnelZoneOverlapCoefficient) {
        _isFresnelZoneBlocked = true;
      }
    }
    isCalculatiing = false;
    notifyListeners();
  }

  /// Calculate coefficients of line by two points
  /// 
  /// Search for the coefficients A, B, C of equation Ax+By+C=0.
  List<double> _coefficientsOfLine(double x1, double y1, double x2, double y2) {
    double A = y1 - y2;
    double B = x2 - x1;
    double C = x1*y2 - x2*y1;
    return List.unmodifiable([A, B, C]);
  }

  /// Calculate distance from point to line
  /// 
  /// If distance < 0 then the point is below the line of sight.
  /// If distance > 0 then the point is above the line of sight.
  double _distanceFromPointToLine(double x, double y, List<double> coefficients) {
    double A = coefficients[0];
    double B = coefficients[1];
    double C = coefficients[2];
    double distance = (A*x + B*y + C) / (sqrt(pow(A, 2) + pow(B, 2)));
    return B > 0 ? distance : -distance;
  }

  /// Find intersection point of line with points (x1, y1), (x2, y2) and perpendecular from (x3, y3)
  List<double> _intersectionPointOfLineAndPerpendecular(
    double x1, double y1,
    double x2, double y2,
    double x3, double y3
  ) {
    double abx = x2 - x1;
    double aby = y2 - y1;
    double dacab = (x3 - x1) * abx + (y3 - y1) * aby;
    double dab = abx * abx + aby * aby;
    double t = dacab / dab;
    double px = x1 + abx * t;
    double py = y1 + aby * t;

    return List.unmodifiable([px, py]);
  }

  // Calculate point by segment AB and perpendicular length from A
  List<double> _pointBySegmentAndLowerPerpendicularLength(double x1, double y1, double x2, double y2, double length) {
    double theta = atan((y2 - y1) / (x2 - x1));
    double x = x1 + length * sin(pi / 2 + (pi / 2 - theta));
    double y = y1 + length * cos(pi / 2 + (pi / 2 - theta));
    return List.unmodifiable([x, y]);
  }

  List<double> _pointBySegmentAndUpperPerpendicularLength(double x1, double y1, double x2, double y2, double length) {
    double theta = atan((y2 - y1) / (x2 - x1));
    double x = x1 + length * cos(pi / 2 + theta);
    double y = y1 + length * sin(pi / 2 + theta);
    return List.unmodifiable([x, y]);
  }

  double _distanceBetweenTwoPoints(double x1, double y1, double x2, double y2) {
    return (sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2)));
  }

  double _radiusOfFirstFresnelZone(double d1, double d2, double freq) {
    double wavelength = Constants.speedOfLight / freq;
    return sqrt(wavelength * (d1 * d2) / (d1 + d2));
  }

  PlotDto? getPlotModel() {
    if (isModelInitialized() && !isCalculatiing) {
      return PlotDto(
        elevationProfileCoordinates: _elevationProfileCoordinates,
        seaLevelPointsCoordinates: _seaLevelCoordinates,
        antennaCoordinates: _antennaCoordinates,
        fresnelZoneCoordiantes: _fresnelZoneCoordiantes,
        isFresnelZoneBlocked: _isFresnelZoneBlocked,
        isLineOfSightBlocked: _isLineOfSightBlocked
      );
    } else {
      return null;
    }
  }
  
}