import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomRangeSlider(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomRangeSlider extends StatefulWidget {
  @override
  _CustomRangeSliderState createState() => _CustomRangeSliderState();
}

class _CustomRangeSliderState extends State<CustomRangeSlider> {
  RangeValues _values = RangeValues(3000, 5000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fake histogram using a Row of Containers
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CustomPaint(
                painter: HistogramPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  thumbColor: Colors.black,
                  rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 12),
                  rangeValueIndicatorShape: PaddleRangeSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.black,
                  valueIndicatorTextStyle: TextStyle(color: Colors.white),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: RangeSlider(
                  values: _values,
                  min: 1000,
                  max: 10000,
                  divisions: 18,
                  labels: RangeLabels(
                    _values.start.toStringAsFixed(0),
                    _values.end.toStringAsFixed(0),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _values = values;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simulated histogram painter (can be replaced with real data)
class HistogramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..strokeWidth = 4;

    final double barSpacing = size.width / 30;

    for (int i = 0; i < 30; i++) {
      final x = i * barSpacing;
      final heightFactor = (i % 5 + 1) / 5;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - (heightFactor * size.height)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}