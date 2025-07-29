import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_plot_model.dart';
import 'package:fresnel_zone_app/util/scroll_behavior.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/presentation/pages/fresnel_zone_page.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FresnelZoneModel(),
        ),
        ChangeNotifierProxyProvider<FresnelZoneModel, FresnelZonePlotModel>(
          create: (_) => FresnelZonePlotModel(),
          update: (_, fresnelZoneModel, fresnelZonePlotModel) => fresnelZonePlotModel!..update(fresnelZoneModel),
        ),
      ],
      child: const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      home: const FresnelZonePage(),
    );
  }
}
