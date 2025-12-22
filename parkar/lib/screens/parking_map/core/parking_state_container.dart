import 'package:flutter/material.dart';
import 'parking_state.dart';

class ParkingMapStateContainer extends StatefulWidget {
  final ParkingMapState state;
  final Widget child;

  const ParkingMapStateContainer({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  State<ParkingMapStateContainer> createState() =>
      _ParkingMapStateContainerState();

  static ParkingMapState of(BuildContext context) {
    final state = context
        .findAncestorStateOfType<_ParkingMapStateContainerState>();
    if (state == null) {
      throw FlutterError(
        'ParkingMapStateContainer no encontrado en el árbol de widgets',
      );
    }
    return state.widget.state;
  }
}

class _ParkingMapStateContainerState extends State<ParkingMapStateContainer> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(ParkingMapStateContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_onStateChanged);
      widget.state.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
