import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/plot_dto.dart';

class FresnelZonePlotPainter extends CustomPainter {

  PlotDto? coordinates;

  FresnelZonePlotPainter(this.coordinates);

  @override
  void paint(Canvas canvas, Size size) {
    if (coordinates == null) {
      return;
    }

    var elevationProfilePoints = coordinates!.elevationProfileCoordinates;
    var seaLevelPoints = coordinates!.seaLevelPointsCoordinates;

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 155, 83, 2)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    Path path = Path();

    // Draw elevation profile (and sea level for filling)
    path.moveTo(size.width * elevationProfilePoints[0][0], size.height * elevationProfilePoints[0][1]);
    for (int i = 1; i < elevationProfilePoints.length; i++) {
      path.lineTo(size.width * elevationProfilePoints[i][0], size.height * elevationProfilePoints[i][1]);
    }
    for (int i = seaLevelPoints.length - 1; i >= 0; i--) {
      path.lineTo(size.width * seaLevelPoints[i][0], size.height * seaLevelPoints[i][1]);
    }
    canvas.drawPath(path, paint);

    // Draw sea level
    paint = Paint()
      ..color = const Color.fromARGB(255, 0, 142, 224)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    path = Path();
    path.moveTo(size.width * seaLevelPoints[0][0], size.height * seaLevelPoints[0][1]);
    for (int i = 1; i < seaLevelPoints.length; i++) {
      path.lineTo(size.width * seaLevelPoints[i][0], size.height * seaLevelPoints[i][1]);
    }
    canvas.drawPath(path, paint);


    // Draw antenna heights
    var antennaCoordinates = coordinates!.antennaCoordinates;

    paint = Paint()
      ..color = const Color.fromARGB(255, 75, 226, 15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * elevationProfilePoints.first[0], size.height * elevationProfilePoints.first[1]),
      Offset(size.width * antennaCoordinates[0][0], size.height * antennaCoordinates[0][1]),
      paint
    );
    canvas.drawLine(
      Offset(size.width * elevationProfilePoints.last[0], size.height * elevationProfilePoints.last[1]),
      Offset(size.width * antennaCoordinates[1][0], size.height * antennaCoordinates[1][1]),
      paint
    );


    // Draw antenna's points
    paint = Paint()
      ..color = const Color.fromARGB(255, 247, 8, 247)
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * antennaCoordinates[0][0], size.height * antennaCoordinates[0][1]), 7, paint);
    canvas.drawCircle(Offset(size.width * antennaCoordinates[1][0], size.height * antennaCoordinates[1][1]), 7, paint);


    // Draw fresnel zone
    var fresnelZoneCoordiantes = coordinates!.fresnelZoneCoordiantes;
    paint = Paint()
      ..color = (coordinates!.isFresnelZoneBlocked) ? const Color.fromARGB(146, 230, 40, 6) : const Color.fromARGB(136, 0, 209, 28)
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;
    path = Path();
    path.moveTo(size.width * fresnelZoneCoordiantes[0][0], size.height * fresnelZoneCoordiantes[0][1]);
    for (int i = 1; i < fresnelZoneCoordiantes.length; i++) {
      path.lineTo(size.width * fresnelZoneCoordiantes[i][0], size.height * fresnelZoneCoordiantes[i][1]);
    }
    canvas.drawPath(path, paint);


    // Draw line of sight
    paint = Paint()
      ..color = (coordinates!.isLineOfSightBlocked) ? const Color.fromARGB(255, 230, 40, 6) : const Color.fromARGB(255, 1, 236, 71)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * antennaCoordinates.first[0], size.height * antennaCoordinates.first[1]),
      Offset(size.width * antennaCoordinates.last[0], size.height * antennaCoordinates.last[1]),
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}