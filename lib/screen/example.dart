import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class Data {
  final double x;
  final double y;

  Data(this.x, this.y);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Custom AED Range Selector")),
        body: PriceRangeWidget(),
      ),
    );
  }
}

class PriceRangeWidget extends StatefulWidget {
  @override
  _PriceRangeWidgetState createState() => _PriceRangeWidgetState();
}

class _PriceRangeWidgetState extends State<PriceRangeWidget> {
  late SfRangeValues _values;
  late List<Data> chartData;

  @override
  void initState() {
    super.initState();
    _values = SfRangeValues(5000.0, 50000.0);
    chartData = List.generate(30, (index) => Data(index * 2000, (index % 5 + 1) * 10));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SfRangeSelector(
        min: 1000.0,
        max: 100000.0,
        interval: 5000,
        showTicks: false,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey.shade300,
        enableTooltip: true,
        shouldAlwaysShowTooltip: true,
        tooltipTextFormatterCallback: (actualValue, formattedText) {
          return 'AED ${actualValue.toStringAsFixed(0)}';
        },
       // trackShape: DashedRangeTrackShape(),
        initialValues: _values,
        onChanged: (SfRangeValues value) {
          setState(() {
            _values = value;
          });
        },
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: NumericAxis(isVisible: false),
            primaryYAxis: NumericAxis(isVisible: false),
            series: <ColumnSeries<Data, double>>[
              ColumnSeries<Data, double>(
                dataSource: chartData,
                xValueMapper: (Data sales, _) => sales.x,
                yValueMapper: (Data sales, _) => sales.y,
                pointColorMapper: (_, __) => Colors.blue.shade200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*class DashedRangeTrackShape extends SfRangeTrackShape {
  void paint(
      PaintingContext context,
      Offset offset,
      RenderBox parentBox,
      SfSliderThemeData themeData,
      SfRangeValues currentValues,
      Paint trackPaint,
      Offset startThumbCenter,
      Offset endThumbCenter,
      TextDirection textDirection,
      ) {
    final Paint dashedPaint = Paint()
      ..color = themeData.activeTrackColor!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(startThumbCenter.dx, startThumbCenter.dy)
      ..lineTo(endThumbCenter.dx, endThumbCenter.dy);

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double distance = 0.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        context.canvas.drawPath(segment, dashedPaint);
        distance += dashWidth + dashSpace;
      }
    }
  }
}*/

