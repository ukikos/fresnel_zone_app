import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/dto/selected_point_dto.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_plot_model.dart';
import 'package:provider/provider.dart';

class PlotInfo extends StatefulWidget {
  const PlotInfo({super.key});

  @override
  State<PlotInfo> createState() => _PlotInfoState();
}

class _PlotInfoState extends State<PlotInfo> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Consumer<FresnelZoneModel>(
                builder: (context, model, child) {
                  double? distance = model.getDistance();
                  String distanceText = (distance == null) ? 'неизвестно' : '${distance.toStringAsFixed(3)} м.';
                  return Flexible(
                    child: Text(
                      'Расстояние: $distanceText',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  );
                },
              ),
              Consumer<FresnelZoneModel>(
                builder: (context, model, child) {
                  String count = model.getCountOfPoints().toString();
                  count = (count == 'null') ? 'неизвестно' : count;
                  return Flexible(
                    child: Text(
                      'Количество точек: $count',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container()
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Flexible(
                child: Consumer<FresnelZonePlotModel>(
                  builder: (context, plotModel, child) {
                    SelectedPointDto? selectedPoint = plotModel.getSelectedPoint();
                    return Text(
                      (selectedPoint == null) ? '' : 'd1: ${selectedPoint.d1.toStringAsFixed(3)} м.',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    );
                  },
                ),
              ),
              Flexible(
                child: Consumer<FresnelZonePlotModel>(
                  builder: (context, plotModel, child) {
                    SelectedPointDto? selectedPoint = plotModel.getSelectedPoint();
                    return Text(
                      (selectedPoint == null) ? '' : 'd2: ${selectedPoint.d2.toStringAsFixed(3)} м.',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    );
                  },
                ),
              ),
              Flexible(
                child: Consumer<FresnelZonePlotModel>(
                  builder: (context, plotModel, child) {
                    SelectedPointDto? selectedPoint = plotModel.getSelectedPoint();
                    if (selectedPoint == null) {
                      return Text(
                        '',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      );
                    } else {
                      return Text(
                        (selectedPoint.elevationOfProfile == null)
                          ? 'Высота рельефа: неизвестно'
                          : 'Высота рельефа: ${selectedPoint.elevationOfProfile!.toStringAsFixed(3)} м.',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      );
                    }
                  },
                ),
              ),
              Flexible(
                child: Consumer<FresnelZonePlotModel>(
                  builder: (context, plotModel, child) {
                    SelectedPointDto? selectedPoint = plotModel.getSelectedPoint();
                    return Text(
                      (selectedPoint == null) ? '' : 'Высота точки над уровнем моря: ${selectedPoint.heightAboveSeaLevel.toStringAsFixed(3)} м.',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}