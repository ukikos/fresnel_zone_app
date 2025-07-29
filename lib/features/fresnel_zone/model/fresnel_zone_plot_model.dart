import 'package:flutter/foundation.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/plot_dto.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';

class FresnelZonePlotModel extends ChangeNotifier{

  PlotDto? scaledPlot;

  void update(FresnelZoneModel model) {
    PlotDto? plotDto = model.getPlotModel();
    if (plotDto == null) {
      return;
    } else {
      scaledPlot = scalePlot(plotDto, 0.02, 0.02, 0.98, 0.98);
      notifyListeners();
    }
  }

  PlotDto scalePlot(PlotDto model, double newMinX, double newMinY, double newMaxX, double newMaxY) {
    List<List<List<double>>> coordinates = [
      model.elevationProfileCoordinates,
      model.seaLevelPointsCoordinates,
      model.antennaCoordinates,
      model.fresnelZoneCoordiantes
    ];

    List<double> range = findCoordinatesRangeOfPlot(coordinates);

    List<List<List<double>>> scaledCoordinates = [];

    double oldMinX = range[0];
    double oldMaxX = range[2];
    double oldRangeX = oldMaxX - oldMinX;
    double newRangeX = newMaxX - newMinX;

    double oldMinY = range[1];
    double oldMaxY = range[3];
    double oldRangeY = oldMaxY - oldMinY;
    double newRangeY = newMaxY - newMinY;

    for (int i = 0; i < coordinates.length; i++) {
      List<List<double>> object = [];
      for (int k = 0; k < coordinates[i].length; k++) {
        double newX = (((coordinates[i][k][0] - oldMinX) * newRangeX) / oldRangeX) + newMinX;
        double newY = 1 - ((((coordinates[i][k][1] - oldMinY) * newRangeY) / oldRangeY) + newMinY);
        object.add([newX, newY]);
      }
      scaledCoordinates.add(object);
    }

    return PlotDto(
      elevationProfileCoordinates: scaledCoordinates[0],
      seaLevelPointsCoordinates: scaledCoordinates[1],
      antennaCoordinates: scaledCoordinates[2],
      fresnelZoneCoordiantes: scaledCoordinates[3],
      isFresnelZoneBlocked: model.isFresnelZoneBlocked,
      isLineOfSightBlocked: model.isLineOfSightBlocked
    );
  }

  /// Find [minX, minY, maxX, maxY]
  List<double> findCoordinatesRangeOfPlot(List<List<List<double>>> coordinates) {

    double minX = double.maxFinite;
    double minY = double.maxFinite;
    double maxX = -double.maxFinite;
    double maxY = -double.maxFinite;

    for (int i = 0; i < coordinates.length; i++) {
      for (int k = 0; k < coordinates[i].length; k++) {
        minX = (coordinates[i][k][0] < minX) ? coordinates[i][k][0] : minX;
        minY = (coordinates[i][k][1] < minY) ? coordinates[i][k][1] : minY;
        maxX = (coordinates[i][k][0] > maxX) ? coordinates[i][k][0] : maxX;
        maxY = (coordinates[i][k][1] > maxY) ? coordinates[i][k][1] : maxY;
      }
    }
    
    return List.unmodifiable([minX, minY, maxX, maxY]);
  }
}