import 'package:mobx/mobx.dart';

part 'misc_state.g.dart';

class MiscState = _MiscStateBase with _$MiscState;

abstract class _MiscStateBase with Store {
  List<List<String>> tabula_recta = [];

  void initialize_tabula_recta() {}
}
