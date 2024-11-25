import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';

class PlayerFormScreen extends StatefulWidget {
  final Player? player;
  final void Function(String name, String fullName, {String? id}) onSavePlayer;

  const PlayerFormScreen({super.key, this.player, required this.onSavePlayer});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.player != null) {
      _nameController.text = widget.player!.name;
      _fullNameController.text = widget.player!.fullName ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.player == null
            ? const Text("Create a Player")
            : const Text("Update a Player"),
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
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _onSubmitPlayer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onSavePlayer(_nameController.text, _fullNameController.text,
        id: widget.player?.id);
  }
}
