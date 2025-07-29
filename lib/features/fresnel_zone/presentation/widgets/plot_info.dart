import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';
import 'package:provider/provider.dart';

class PlotInfo extends StatefulWidget {
  const PlotInfo({super.key});

  @override
  State<PlotInfo> createState() => _PlotInfoState();
}

class _PlotInfoState extends State<PlotInfo> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Consumer<FresnelZoneModel>(
            builder: (context, model, child) {
              String distance = model.getDistance().toString();
              distance = (distance == 'null') ? 'неизвестно' : '$distance м.';
              return Text(
                'Расстояние: $distance',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.clip,
              );
            },
          ),
          Consumer<FresnelZoneModel>(
            builder: (context, model, child) {
              String count = model.getCountOfPoints().toString();
              count = (count == 'null') ? 'неизвестно' : count;
              return Text(
                'Количество точек: $count',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.clip,
              );
            },
          ),
        ],
      ),
    );
  }
}