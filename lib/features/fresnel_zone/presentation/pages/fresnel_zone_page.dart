import 'package:flutter/material.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_plot_model.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/presentation/widgets/fresnel_zone_plot_painter.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/presentation/widgets/input_form_panel.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/presentation/widgets/plot_info.dart';
import 'package:fresnel_zone_app/util/constants.dart';
import 'package:provider/provider.dart';

class FresnelZonePage extends StatefulWidget {
  const FresnelZonePage({super.key});

  @override
  State<FresnelZonePage> createState() => _FresnelZonePageState();
}

class _FresnelZonePageState extends State<FresnelZonePage> {

  @override
  Widget build(BuildContext context) {
    if (!Constants.isFullscreenSizeInitialized) {
      Constants.fullscreenWidth = MediaQuery.of(context).size.width;
      Constants.fullscreenHeight = MediaQuery.of(context).size.height;
      Constants.isFullscreenSizeInitialized = true;
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width >= 310) ? MediaQuery.of(context).size.width - 310 : 0,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 248, 248, 248),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 194, 194, 194),
                                    width: 2,
                                  ),
                                ),
                                child: Consumer<FresnelZonePlotModel>(
                                  builder: (context, plotModel, child) {
                                    return GestureDetector(
                                      onTapUp: (details) {
                                        List<double>? modelPoint = plotModel.scaleCanvasPointCoordinatesToModelCoordinates(
                                          details.localPosition, 
                                          context.size?.width ?? 1, 
                                          context.size?.height ?? 1
                                        );
                                        if (modelPoint != null) {
                                          plotModel.initSelectedPoint(modelPoint[0], modelPoint[1]);
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: CustomPaint(
                                          painter: FresnelZonePlotPainter(plotModel.scaledPlot),
                                          child: Container(),
                                        ),
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: PlotInfo(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: InputFormPanel(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}