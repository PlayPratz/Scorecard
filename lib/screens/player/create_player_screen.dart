import 'package:flutter/material.dart';

class CreatePlayerScreen extends StatelessWidget {
  const CreatePlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            Text("Create a Player",
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: null,
        label: const Text("Create"),
        icon: const Icon(Icons.person_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
