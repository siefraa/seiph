import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/family_tree_provider.dart';
import 'dialogs.dart';

class PersonDetailPanel extends StatelessWidget {
  final Person person;
  const PersonDetailPanel({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FamilyTreeProvider>();
    final spouse = person.spouseId != null ? provider.getPersonById(person.spouseId!) : null;
    final parent = person.parentId != null ? provider.getPersonById(person.parentId!) : null;
    final children = provider.getChildren(person.id);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1923),
        border: Border(left: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: person.gender == Gender.male
                    ? [const Color(0xFF1A3A6B), const Color(0xFF0D1F3C)]
                    : [const Color(0xFF6B1A4A), const Color(0xFF3C0D26)],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white12,
                  child: Text(
                    person.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(person.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      person.gender == Gender.male ? Icons.male : Icons.female,
                      color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text(person.gender.name,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                    if (!person.isAlive) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const Text(' Deceased',
                          style: TextStyle(color: Colors.amber, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (person.birthDate != null)
                    _infoRow(Icons.cake, 'Born', person.birthDate!),
                  if (person.deathDate != null)
                    _infoRow(Icons.star, 'Died', person.deathDate!),
                  if (spouse != null)
                    _infoRow(Icons.favorite, 'Spouse', spouse.name, color: Colors.pink),
                  if (parent != null)
                    _infoRow(Icons.person, 'Parent', parent.name),
                  if (children.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('CHILDREN',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    ...children.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _infoRow(Icons.child_care, '', c.name),
                        )),
                  ],
                  if (person.notes != null) ...[
                    const SizedBox(height: 8),
                    const Text('NOTES',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(person.notes!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  // Action buttons
                  _actionBtn(
                    context, Icons.add_circle_outline, 'Add Child', Colors.green,
                    () => _addChild(context, provider, person),
                  ),
                  const SizedBox(height: 6),
                  _actionBtn(
                    context, Icons.favorite_outline, 'Add/Link Spouse', Colors.pink,
                    () => _linkSpouse(context, provider, person),
                  ),
                  const SizedBox(height: 6),
                  _actionBtn(
                    context, Icons.link, 'Link as Child of...', Colors.orange,
                    () => _linkAsChild(context, provider, person),
                  ),
                  const SizedBox(height: 6),
                  if (person.spouseId != null)
                    _actionBtn(
                      context, Icons.heart_broken, 'Unlink Spouse', Colors.red.shade300,
                      () {
                        provider.unlinkSpouse(person.id);
                        Navigator.pop(context);
                      },
                    ),
                  if (person.parentId != null) ...[
                    const SizedBox(height: 6),
                    _actionBtn(
                      context, Icons.link_off, 'Unlink from Parent', Colors.red.shade300,
                      () {
                        provider.unlinkParentChild(person.parentId!, person.id);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                  const SizedBox(height: 6),
                  _actionBtn(
                    context, Icons.edit, 'Edit', Colors.blue,
                    () => _editPerson(context, provider, person),
                  ),
                  const SizedBox(height: 6),
                  _actionBtn(
                    context, Icons.delete_outline, 'Delete', Colors.red,
                    () => _deletePerson(context, provider, person),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white38, size: 14),
          const SizedBox(width: 6),
          if (label.isNotEmpty) ...[
            Text('$label: ',
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
          Expanded(
            child: Text(value,
                style: TextStyle(color: color ?? Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext ctx, IconData icon, String label, Color color,
      VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          alignment: Alignment.centerLeft,
          backgroundColor: color.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _addChild(BuildContext context, FamilyTreeProvider provider, Person parent) async {
    final result = await showDialog<Person>(
      context: context,
      builder: (_) => const AddPersonDialog(title: 'Add Child'),
    );
    if (result != null) {
      result.parentId = parent.id;
      provider.addChildPerson(parent.id, result);
    }
  }

  Future<void> _linkSpouse(BuildContext context, FamilyTreeProvider provider, Person person) async {
    // Option to add new or link existing
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Spouse', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: const Text('Add New Person as Spouse',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'new'),
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text('Link Existing Person',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'existing'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'new') {
      final result = await showDialog<Person>(
        context: context,
        builder: (_) => AddPersonDialog(
          title: 'Add Spouse',
          initial: Person(
            id: '',
            name: '',
            gender: person.gender == Gender.male ? Gender.female : Gender.male,
          ),
        ),
      );
      if (result != null) {
        final spouseId = provider.addPerson(
          name: result.name,
          gender: result.gender,
          birthDate: result.birthDate,
          deathDate: result.deathDate,
          notes: result.notes,
          isAlive: result.isAlive,
        );
        provider.linkAsSpouse(person.id, spouseId);
      }
    } else if (choice == 'existing') {
      final selectedId = await showDialog<String>(
        context: context,
        builder: (_) => LinkPersonDialog(
          persons: provider.persons,
          title: 'Link as Spouse',
          excludeId: person.id,
        ),
      );
      if (selectedId != null) {
        provider.linkAsSpouse(person.id, selectedId);
      }
    }
  }

  Future<void> _linkAsChild(BuildContext context, FamilyTreeProvider provider, Person person) async {
    final selectedId = await showDialog<String>(
      context: context,
      builder: (_) => LinkPersonDialog(
        persons: provider.persons,
        title: 'Select Parent',
        excludeId: person.id,
      ),
    );
    if (selectedId != null) {
      provider.linkParentChild(selectedId, person.id);
    }
  }

  Future<void> _editPerson(BuildContext context, FamilyTreeProvider provider, Person person) async {
    final result = await showDialog<Person>(
      context: context,
      builder: (_) => AddPersonDialog(title: 'Edit Person', initial: person),
    );
    if (result != null) {
      provider.updatePerson(result);
    }
  }

  Future<void> _deletePerson(BuildContext context, FamilyTreeProvider provider, Person person) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Person', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete ${person.name}?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      provider.deletePerson(person.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
