

import 'dart:async';

class ProgressBloc {
  final _stateStreamController = StreamController<double>();

  StreamSink<double> get progressSink => _stateStreamController.sink;
  Stream<double> get progressStream => _stateStreamController .stream;
}