import 'dart:math';

class GeometryService {

  /// Calculate coefficients of line by two points
  /// 
  /// Search for the coefficients A, B, C of equation Ax+By+C=0.
  List<double> coefficientsOfLine(double x1, double y1, double x2, double y2) {
    double A = y1 - y2;
    double B = x2 - x1;
    double C = x1*y2 - x2*y1;
    return List.unmodifiable([A, B, C]);
  }

  /// Calculate distance from point to line
  /// 
  /// If distance < 0 then the point is below the line of sight.
  /// If distance > 0 then the point is above the line of sight.
  double distanceFromPointToLine(double x, double y, List<double> coefficients) {
    double A = coefficients[0];
    double B = coefficients[1];
    double C = coefficients[2];
    double distance = (A*x + B*y + C) / (sqrt(pow(A, 2) + pow(B, 2)));
    return B > 0 ? distance : -distance;
  }

  /// Find intersection point of line with points (x1, y1), (x2, y2) and perpendecular from (x3, y3)
  List<double> intersectionPointOfLineAndPerpendecular(
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
  List<double> pointBySegmentAndLowerPerpendicularLength(double x1, double y1, double x2, double y2, double length) {
    double theta = atan((y2 - y1) / (x2 - x1));
    double x = x1 + length * sin(pi / 2 + (pi / 2 - theta));
    double y = y1 + length * cos(pi / 2 + (pi / 2 - theta));
    return List.unmodifiable([x, y]);
  }

  List<double> pointBySegmentAndUpperPerpendicularLength(double x1, double y1, double x2, double y2, double length) {
    double theta = atan((y2 - y1) / (x2 - x1));
    double x = x1 + length * cos(pi / 2 + theta);
    double y = y1 + length * sin(pi / 2 + theta);
    return List.unmodifiable([x, y]);
  }

  double distanceBetweenTwoPoints(double x1, double y1, double x2, double y2) {
    return (sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2)));
  }

  List<double> cartesianToPolar(List<double> coordinates) {
    double r = sqrt(pow(coordinates[0], 2) + pow(coordinates[1], 2));
    double phi = atan2(coordinates[0], coordinates[1]);
    return List.unmodifiable([r, phi]);
  }

  List<double> intersectionPointOfLines(
    List<double> p1,
    List<double> p2,
    List<double> p3,
    List<double> p4,
  ) {

    double x = ((p1[0] * p2[1] - p1[1] * p2[0]) * (p3[0] - p4[0]) - (p1[0] - p2[0]) * (p3[0] * p4[1] - p3[1] * p4[0]))
      / ((p1[0] - p2[0]) * (p3[1] - p4[1]) - (p1[1] - p2[1]) * (p3[0] - p4[0]));

    double y = ((p1[0] * p2[1] - p1[1] * p2[0]) * (p3[1] - p4[1]) - (p1[1] - p2[1]) * (p3[0] * p4[1] - p3[1] * p4[0]))
      / ((p1[0] - p2[0]) * (p3[1] - p4[1]) - (p1[1] - p2[1]) * (p3[0] - p4[0]));

    return List.unmodifiable([x, y]);
  }
}