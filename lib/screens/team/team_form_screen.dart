import 'package:flutter/material.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class TeamFormScreen extends StatefulWidget {
  final Team? team;

  final void Function({
    required String name,
    required String short,
    required int color,
  }) onSaveTeam;

  const TeamFormScreen(this.team, {super.key, required this.onSaveTeam});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _nameController = TextEditingController();
  final _shortController = TextEditingController();
  int _color = DateTime.now().microsecondsSinceEpoch % _colors.length;

  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.team != null) {
      _nameController.text = widget.team!.name;
      _shortController.text = widget.team!.short;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.team == null
            ? const Text("Create a Team")
            : Text(widget.team!.name),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: [
            if (widget.team != null)
              Text(
                "#${widget.team!.id}",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.black54),
                textAlign: TextAlign.right,
              ),
            ListTile(
              title: TextFormField(
                controller: _shortController,
                maxLength: 4,
                decoration: const InputDecoration(hintText: "Short Name"),
                validator: (str) {
                  if (str == null || str.isEmpty) {
                    return "Please enter a short name";
                  }
                  return null;
                },
              ),
              trailing: GestureDetector(
                onTap: nextColor,
                child: CircleAvatar(
                  backgroundColor: _colors[_color],
                ),
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: _nameController,
                maxLength: 32,
                decoration: const InputDecoration(hintText: "Team Name"),
                validator: (str) {
                  if (str == null || str.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: submit,
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }

  void nextColor() {
    setState(() {
      _color = (_color + 1) % _colors.length;
    });
  }

  Future<void> submit() async {
    if (!_key.currentState!.validate()) {
      return;
    }
    final name = _nameController.text;
    final short = _shortController.text;
    final color = _colors[_color].value;
    widget.onSaveTeam(name: name, short: short, color: color);
    Navigator.pop(context);
  }
}

final _colors = [
  Colors.red.shade900,
  Colors.blue.shade800,
  Colors.deepPurple.shade600,
  Colors.yellow.shade700,
  Colors.green.shade600,
  Colors.deepOrange.shade900,
  Colors.purple.shade400,
];
