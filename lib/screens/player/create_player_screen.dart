import 'package:flutter/material.dart';

class CreatePlayerScreen extends StatefulWidget {
  const CreatePlayerScreen({super.key});

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 10,
                decoration: const InputDecoration(hintText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _fullNameController,
                maxLength: 32,
                decoration:
                    const InputDecoration(hintText: "Full Name (optional)"),
                validator: (_) => null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _onSubmitPlayer,
              label: const Text("Create"),
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onSubmitPlayer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
  }
}
