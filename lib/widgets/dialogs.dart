import 'package:flutter/material.dart';
import '../models/person.dart';
import '../providers/family_tree_provider.dart';
import 'package:uuid/uuid.dart';

class AddPersonDialog extends StatefulWidget {
  final String title;
  final Person? initial;
  const AddPersonDialog({super.key, this.title = 'Add Person', this.initial});

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  final _nameCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _deathCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  Gender _gender = Gender.male;
  bool _isAlive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.name;
      _birthCtrl.text = widget.initial!.birthDate ?? '';
      _deathCtrl.text = widget.initial!.deathDate ?? '';
      _notesCtrl.text = widget.initial!.notes ?? '';
      _gender = widget.initial!.gender;
      _isAlive = widget.initial!.isAlive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthCtrl.dispose();
    _deathCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(_nameCtrl, 'Full Name *', Icons.person),
            const SizedBox(height: 12),
            // Gender selection
            Row(
              children: [
                const Text('Gender:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                _genderChip('Male', Gender.male, Colors.blue),
                const SizedBox(width: 8),
                _genderChip('Female', Gender.female, Colors.pink),
                const SizedBox(width: 8),
                _genderChip('Other', Gender.other, Colors.purple),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(_birthCtrl, 'Birth Year / Date', Icons.cake),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Alive', style: TextStyle(color: Colors.white70)),
                Switch(
                  value: _isAlive,
                  onChanged: (v) => setState(() => _isAlive = v),
                  activeColor: const Color(0xFF52B788),
                ),
              ],
            ),
            if (!_isAlive) ...[
              _buildField(_deathCtrl, 'Death Year / Date', Icons.star),
              const SizedBox(height: 8),
            ],
            _buildField(_notesCtrl, 'Notes', Icons.notes, maxLines: 2),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6E49)),
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            final p = Person(
              id: widget.initial?.id ?? const Uuid().v4(),
              name: _nameCtrl.text.trim(),
              gender: _gender,
              birthDate: _birthCtrl.text.trim().isEmpty ? null : _birthCtrl.text.trim(),
              deathDate: _deathCtrl.text.trim().isEmpty ? null : _deathCtrl.text.trim(),
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              isAlive: _isAlive,
              spouseId: widget.initial?.spouseId,
              parentId: widget.initial?.parentId,
              childrenIds: widget.initial?.childrenIds ?? [],
            );
            Navigator.pop(context, p);
          },
          child: Text(widget.initial != null ? 'Update' : 'Add',
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _genderChip(String label, Gender g, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _gender = g),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _gender == g ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gender == g ? color : Colors.grey),
        ),
        child: Text(label,
            style: TextStyle(
                color: _gender == g ? color : Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class LinkPersonDialog extends StatefulWidget {
  final List<Person> persons;
  final String title;
  final String? excludeId;

  const LinkPersonDialog({
    super.key,
    required this.persons,
    required this.title,
    this.excludeId,
  });

  @override
  State<LinkPersonDialog> createState() => _LinkPersonDialogState();
}

class _LinkPersonDialogState extends State<LinkPersonDialog> {
  String? _selectedId;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.persons
        .where((p) =>
            p.id != widget.excludeId &&
            p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search person...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final p = filtered[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          p.gender == Gender.male ? Colors.blue.withOpacity(0.3) : Colors.pink.withOpacity(0.3),
                      child: Text(p.name[0],
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: p.birthDate != null
                        ? Text(p.birthDate!,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11))
                        : null,
                    selected: _selectedId == p.id,
                    selectedTileColor: const Color(0xFF2C6E49).withOpacity(0.3),
                    onTap: () => setState(() => _selectedId = p.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6E49)),
          onPressed: _selectedId != null ? () => Navigator.pop(context, _selectedId) : null,
          child: const Text('Link', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
