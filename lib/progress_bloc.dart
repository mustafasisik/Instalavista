import 'dart:async';

class ProgressBloc {

  final _streamController = StreamController<double>();

  StreamSink<double> get progressSink => _streamController.sink;
  Stream<double> get progressStream => _streamController.stream;

}