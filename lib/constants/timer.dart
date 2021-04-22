class TimeCode {
  TimeCode({this.identifier}) : start_time = DateTime.now();
  final DateTime start_time;
  final String identifier;

  void stop_print() {
    final stopTime = DateTime.now();

    print('$identifier | ${stopTime.difference(start_time)}');
  }

  int stop() {
    return DateTime.now().millisecondsSinceEpoch - start_time.millisecondsSinceEpoch;
  }
}
