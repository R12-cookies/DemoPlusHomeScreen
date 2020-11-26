import 'package:flutter/material.dart';

class Haha extends StatefulWidget {
  @override
  _HahaState createState() => _HahaState();
}

class _HahaState extends State<Haha> {
  double initial = 0.0;
  double percentage = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onVerticalDragStart: (DragStartDetails details) {
            initial = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            double distance = details.globalPosition.dy - initial;
            double percentageAddition = distance / 200;
            setState(() {
              percentage = (percentage + percentageAddition).clamp(0.0, 100.0);
            });
          },
          onVerticalDragDown: (DragDownDetails details) {
            initial = 0.0;
          },
          child: Container(),
        ),
      ),
    );
  }
}
