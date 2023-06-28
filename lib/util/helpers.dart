import 'package:flutter/material.dart';

class Helpers {
  Helpers._();
}

class SingleSelectionToggle<T> {
  final List<T> dataList;
  final bool allowNoSelection;
  final String Function(T data)? stringifier;
  final Widget Function(T data, T? selection) widgetifier;
  int index = -1;

  SingleSelectionToggle({
    required this.dataList,
    required this.stringifier,
    this.allowNoSelection = true,
  }) : widgetifier = ((data, selection) => Text(stringifier!(data))) {
    clear();
  }

  SingleSelectionToggle.withWidgetifier(
      {required this.dataList,
      this.allowNoSelection = true,
      required this.widgetifier})
      : stringifier = null {
    clear();
  }

  T? get selection => index == -1 ? null : dataList[index];
  set selection(T? value) =>
      index = value != null ? dataList.indexOf(value) : -1;

  List<bool> get booleans => dataList.map((data) => data == selection).toList();
  List<Widget> get widgets =>
      dataList.map((data) => widgetifier(data, selection)).toList();

  Set<T> get selectionSet => {dataList[index]};

  void clear() {
    index = allowNoSelection ? -1 : 0;
  }
}
