import 'package:flutter/material.dart';

class SimplifiedFutureBuilder<T> extends StatelessWidget {
  /// The future that holds some data
  final Future<T> future;

  /// The desired child that will be built once the data is fetched
  final Widget Function(BuildContext context, T data) builder;

  /// A widget to show when loading
  final Widget? loading;

  const SimplifiedFutureBuilder(
      {super.key, required this.future, required this.builder, this.loading});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text("Error!"),
                  Text(snapshot.error.toString()),
                ],
              ),
            ); // TODO handle errors
          }
          if (snapshot.hasData) {
            return builder(context, snapshot.data!);
          }
        }
        if (loading != null) {
          return loading!;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
