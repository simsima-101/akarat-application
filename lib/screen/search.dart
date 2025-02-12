import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double _min = 2.0;
  final double _max = 30.0;
  final SfRangeValues _values = SfRangeValues(12.5, 20.5);
  late RangeController _rangeController;


  @override
  void initState() {
    super.initState();
    _rangeController = RangeController(
        start: _values.start,
        end: _values.end);
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }



  final List<Data> chartData = <Data>[
    Data(x: 2.0, y: 9.2),
    Data(x: 3.0, y: 23.4),
    Data(x: 4.0, y: 4.13),
    Data(x: 5.0, y: 15.6),
    Data(x: 6.0, y: 6.3),
    Data(x: 7.0, y: 7.12),
    Data(x: 8.0, y: 18.9),
    Data(x: 9.0, y: 9.8),
    Data(x: 10.0, y:19.7),
    Data(x: 11.0, y: 11.11),
    Data(x: 12.0, y: 12.5),
    Data(x: 13.0, y: 13.7),
    Data(x: 14.0, y: 20.8),
    Data(x: 15.0, y: 6.7),
    Data(x: 16.0, y: 16.7),
    Data(x: 17.0, y: 17.7),
    Data(x: 18.0, y: 22.7),
    Data(x: 19.0, y: 19.7),
    Data(x: 20.0, y: 11.7),
    Data(x: 21.0, y: 20.7),
    Data(x: 22.0, y: 9.7),
    Data(x: 23.0, y: 8.7),
    Data(x: 24.0, y: 12.7),
    Data(x: 25.0, y: 15.7),
    Data(x: 26.0, y: 26.7),
    Data(x: 27.0, y: 14.7),
    Data(x: 28.0, y: 20.7),
    Data(x: 29.0, y: 15.7),
    Data(x: 30.0, y: 13.7),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SfRangeSelector(
          min: _min,
          max: _max,
          interval: 1,
          enableTooltip: true,
          shouldAlwaysShowTooltip: true,
          initialValues: _values,
          child: SizedBox(
            height: 70,
            width: 400,
            child: SfCartesianChart(
              plotAreaBorderColor: Colors.transparent,
              margin: const EdgeInsets.all(0),
              primaryXAxis: NumericAxis(minimum: _min, maximum: _max,
                isVisible: false,),
              primaryYAxis: NumericAxis(isVisible: false),
              plotAreaBorderWidth: 0,
              plotAreaBackgroundColor: Colors.transparent,
              series: <ColumnSeries<Data, double>>[
                ColumnSeries<Data, double>(
                  trackColor: Colors.transparent,
                  // color: Color.fromARGB(255, 126, 184, 253),
                  dataSource: chartData,
                  selectionBehavior: SelectionBehavior(
                    unselectedOpacity: 0,
                    selectedOpacity: 1.5,unselectedColor: Colors.transparent,
                    selectionController: _rangeController,
                  ),
                  xValueMapper: (Data sales, int index) => sales.x,
                  yValueMapper: (Data sales, int index) => sales.y,
                  pointColorMapper: (Data sales, int index) {
// if((_rangeController.start)  && (_rangeController.end){
                   return const Color.fromRGBO(0, 178, 206, 1);
// }
// return Colors.transparent;

                    // if (sales.x(_rangeController.start) &&
                    //     sales.x(_rangeController.end)) {


                    // }
                    // return Colors.transparent;
                  },
                  // color: const Color.fromRGBO(255, 255, 255, 0),
                  dashArray: const <double>[5, 3],
                 // borderColor: const Color.fromRGBO(194, 194, 194, 1),
                  animationDuration: 0,
                  borderWidth: 0,
                  //opacity: 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  class Data {
  Data({required this.x, required this.y});
  final double x;
  final double y;
  }