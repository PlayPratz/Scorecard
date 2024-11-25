import 'package:flutter/material.dart';

class LoadingFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;

  final Widget Function(BuildContext context, T data) builder;
  final Widget? onError;
  final Widget? child;

  const LoadingFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.onError,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return onError ?? const Text("Error!");
              }
              if (snapshot.hasData) {
                return builder(context, snapshot.data as T);
              }
              return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
