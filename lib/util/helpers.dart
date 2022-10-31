import 'package:flutter/material.dart';

class Helpers {
  Helpers._();
}

class SingleToggleSelection<T> {
  final List<T> dataList;
  final bool allowNoSelection;
  final String Function(T data)? stringifier;
  final Widget Function(T data, T? selection) widgetifier;
  int index = -1;

  SingleToggleSelection({
    required this.dataList,
    required this.stringifier,
    this.allowNoSelection = true,
  }) : widgetifier = ((data, selection) => Text(stringifier!(data))) {
    clear();
  }

  SingleToggleSelection.withWidgetifier(
      {required this.dataList,
      this.allowNoSelection = true,
      required this.widgetifier})
      : stringifier = null {
    clear();
  }

  T? get selection => index == -1 ? null : dataList[index];
  set selection(T? value) =>
      value != null ? index = dataList.indexOf(value) : -1;

  List<bool> get booleans => dataList.map((data) => data == selection).toList();
  List<Widget> get widgets =>
      dataList.map((data) => widgetifier(data, selection)).toList();

  void clear() {
    index = allowNoSelection ? -1 : 0;
  }
}
