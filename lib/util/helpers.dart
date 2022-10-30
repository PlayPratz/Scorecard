import 'package:flutter/material.dart';

class Helpers {
  Helpers._();
}

class SingleToggleSelection<T> {
  final List<T> dataList;
  final String Function(T) stringifier;
  final bool allowNoSelection;
  int index = -1;

  SingleToggleSelection(
      {required this.dataList,
      required this.stringifier,
      this.allowNoSelection = true}) {
    clear();
  }

  T? get selection => index == -1 ? null : dataList[index];

  List<Widget> get widgets =>
      dataList.map((data) => Text(stringifier(data))).toList();

  List<bool> get booleans => dataList.map((data) => data == selection).toList();

  void clear() {
    index = allowNoSelection ? -1 : 0;
  }
}
