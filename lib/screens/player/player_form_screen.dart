import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/services/settings_service.dart';

class PlayerFormScreen extends StatefulWidget {
  final Player? player;
  final PlayerCallbackFn onSavePlayer;

  const PlayerFormScreen({super.key, this.player, required this.onSavePlayer});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _nameController = TextEditingController();
  // final _fullNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.player != null) {
      _nameController.text = widget.player!.name;
      // _fullNameController.text = widget.player!.fullName ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final showIds = context.read<SettingsService>().getShowHandles();

    return Scaffold(
      appBar: AppBar(
        title: widget.player == null
            ? const Text("Create a Player")
            : Text(widget.player!.name),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: [
            if (widget.player != null && showIds)
              Text(
                "#${widget.player!.id}",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.black54),
                textAlign: TextAlign.right,
              ),
            ListTile(
              title: TextFormField(
                controller: _nameController,
                maxLength: 10,
                decoration: const InputDecoration(hintText: "Name"),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
            ),
            // ListTile(
            //   title: TextFormField(
            //     controller: _fullNameController,
            //     maxLength: 32,
            //     decoration:
            //         const InputDecoration(hintText: "Full Name (optional)"),
            //     validator: (_) => null,
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FilledButton.icon(
          onPressed: _onSubmitPlayer,
          label: const Text("Save"),
          icon: _isLoading
              ? const CircularProgressIndicator()
              : const Icon(Icons.save),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _onSubmitPlayer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final player = await context.read<PlayerService>().savePlayer(
          id: widget.player?.id,
          handle: widget.player?.handle,
          name: _nameController.text,
        );

    widget.onSavePlayer(player);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
