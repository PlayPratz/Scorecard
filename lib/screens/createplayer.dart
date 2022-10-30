import 'package:flutter/material.dart';
import 'titledpage.dart';

class CreatePlayerForm extends StatefulWidget {
  const CreatePlayerForm({Key? key}) : super(key: key);

  @override
  State<CreatePlayerForm> createState() => _CreatePlayerFormState();
}

class _CreatePlayerFormState extends State<CreatePlayerForm> {
  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: "Create a Player",
        child: SingleChildScrollView(
          child: Column(
            children: [],
          ),
        ));
  }
}
