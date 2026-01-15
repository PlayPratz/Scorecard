import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _fullNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? _dateOfBirth;
  final _dobController = TextEditingController();

  bool _isLoading = false;

  final dateFormat = DateFormat.yMMMd("en_IN");

  @override
  void initState() {
    super.initState();

    if (widget.player != null) {
      _nameController.text = widget.player!.name;
      _fullNameController.text = widget.player!.fullName ?? "";
      _dateOfBirth = widget.player!.dateOfBirth;
      if (_dateOfBirth != null) {
        _dobController.text = dateFormat.format(_dateOfBirth!);
      }
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
                "#${widget.player!.handle}",
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.black54),
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
            ListTile(
              title: TextFormField(
                controller: _fullNameController,
                maxLength: 32,
                decoration: const InputDecoration(
                  hintText: "Full Name (optional)",
                ),
                textCapitalization: TextCapitalization.words,
                validator: (_) => null,
              ),
            ),
            ListTile(
              title: TextFormField(
                onTap: () async {
                  // Prevent keyboard from opening
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    currentDate: _dateOfBirth,
                    // initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                  setState(() {
                    _dateOfBirth = date;
                    if (_dateOfBirth != null) {
                      _dobController.text = dateFormat.format(_dateOfBirth!);
                    }
                  });
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.calendar_month),
                  hint: const Text("Date of Birth (optional)"),
                  suffix: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _dateOfBirth = null;
                      _dobController.clear();
                    },
                    padding: const EdgeInsets.all(0),
                  ),
                ),
                controller: _dobController,
                validator: (_) => null,
              ),
            ),
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
      fullName: _fullNameController.text,
      dob: _dateOfBirth,
    );

    widget.onSavePlayer(player);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
