import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/plot_dto.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/selected_point_dto.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/service/geometry_service.dart';
import 'package:fresnel_zone_app/util/constants.dart';

class FresnelZonePlotModel extends ChangeNotifier{

  final GeometryService _geometryService = GeometryService();

  PlotDto? plotModel;
  PlotDto? scaledPlot;

  SelectedPointDto? selectedPoint;

  void update(FresnelZoneModel model) {
    selectedPoint = null;
    PlotDto? plotDto = model.getPlotModel();
    if (plotDto == null) {
      return;
    } else {
      plotModel = plotDto;
      scaledPlot = scalePlot(
        plotModel!, 
        Constants.canvasRangeOfValues[0], 
        Constants.canvasRangeOfValues[1], 
        Constants.canvasRangeOfValues[2], 
        Constants.canvasRangeOfValues[3]
      );
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

    List<double> range = findRangeOfCoordinateValues(coordinates);

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
        // 1 - (...) because the origin of coordinates is from the upper left corner
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
  List<double> findRangeOfCoordinateValues(List<List<List<double>>> coordinates) {

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


  List<double>? scaleCanvasPointCoordinatesToModelCoordinates(Offset offset, double canvasWidth, double canvasHeight) {

    if (plotModel == null) {
      return null;
    }

    double plotX = offset.dx / canvasWidth;
    double plotY = offset.dy / canvasHeight;

    List<List<List<double>>> modelCoordinates = [
      plotModel!.elevationProfileCoordinates,
      plotModel!.seaLevelPointsCoordinates,
      plotModel!.antennaCoordinates,
      plotModel!.fresnelZoneCoordiantes
    ];

    List<double> modelRange = findRangeOfCoordinateValues(modelCoordinates);
    List<double> plotRange = Constants.canvasRangeOfValues;

    double oldMinX = plotRange[0];
    double oldMaxX = plotRange[2];
    double oldRangeX = oldMaxX - oldMinX;
    double newRangeX = modelRange[2] - modelRange[0];
    double newMinX = modelRange[0];

    double oldMinY = plotRange[1];
    double oldMaxY = plotRange[3];
    double oldRangeY = oldMaxY - oldMinY;
    double newRangeY = modelRange[3] - modelRange[1];
    double newMinY = modelRange[1];

    double scaledX = (((plotX - oldMinX) * newRangeX) / oldRangeX) + newMinX;
    // 1 - (...) because the origin of coordinates is from the upper left corner
    double scaledY = (((1 - plotY - oldMinY) * newRangeY) / oldRangeY) + newMinY;

    return List.unmodifiable([scaledX, scaledY]);
  }

  void initSelectedPoint(double x, double y) {
    selectedPoint = SelectedPointDto(
      d1: getD1AtPoint(x, y),
      d2: getD2AtPoint(x, y),
      heightAboveSeaLevel: getHeightAboveSeaLevelAtPoint(x, y),
      elevationOfProfile: getElevationOfProfileAtIntermediatePoint(x, y)
    );
    notifyListeners();
  }

  SelectedPointDto? getSelectedPoint() {
    return selectedPoint;
  }

  double getD1AtPoint(double x, double y) {
    return _geometryService.distanceBetweenTwoPoints(plotModel!.antennaCoordinates.first[0], plotModel!.antennaCoordinates.first[1], x, y);
  }

  double getD2AtPoint(double x, double y) {
    return _geometryService.distanceBetweenTwoPoints(plotModel!.antennaCoordinates.last[0], plotModel!.antennaCoordinates.last[1], x, y);
  }

  double? getElevationOfProfileAtIntermediatePoint(double x, double y) {
    List<double> pointPolar = _geometryService.cartesianToPolar([x, y]);
    double angle = pointPolar[1];

    int? index;

    for (int i = 0; i < plotModel!.elevationProfileCoordinates.length - 1; i++) {
      double ep1_x = plotModel!.elevationProfileCoordinates[i][0];
      double ep1_y = plotModel!.elevationProfileCoordinates[i][1];
      double ep2_x = plotModel!.elevationProfileCoordinates[i+1][0];
      double ep2_y = plotModel!.elevationProfileCoordinates[i+1][1];
      if (angle >= _geometryService.cartesianToPolar([ep1_x, ep1_y])[1] && angle <= _geometryService.cartesianToPolar([ep2_x, ep2_y])[1]) {
        index = i;
        break;
      }
    }

    if (index == null) return null;

    double x1 = x;
    double y1 = y;

    double x2 = 0;
    double y2 = 0;

    double x3 = plotModel!.elevationProfileCoordinates[index][0];
    double y3 = plotModel!.elevationProfileCoordinates[index][1];

    double x4 = plotModel!.elevationProfileCoordinates[index+1][0];
    double y4 = plotModel!.elevationProfileCoordinates[index+1][1];

    List<double> intersectionPoint = _geometryService.intersectionPointOfLines([x1, y1], [x2, y2], [x3, y3], [x4, y4]);

    List<double> intersectionPointPolar = _geometryService.cartesianToPolar(intersectionPoint);
    
    return intersectionPointPolar[0] - Constants.earthRadius;
  }

  double getHeightAboveSeaLevelAtPoint(double x, double y) {
    var pointPolar = _geometryService.cartesianToPolar([x, y]);
    return (pointPolar[0] - Constants.earthRadius);
  }
}