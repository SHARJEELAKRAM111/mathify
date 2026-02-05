import 'package:flutter/material.dart';
import 'package:mathify/features/calculator/domain/models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? existing;
  const NoteEditorScreen({super.key, this.existing});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _title.text = widget.existing!.title;
      _desc.text = widget.existing!.description;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    final d = _desc.text.trim();

    // Light validation
    if (t.isEmpty && d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a title or description first.')),
      );
      return;
    }

    setState(() => _saving = true);

    final notes = await NotesStorage.loadNotes();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        title: t,
        description: d,
        updatedAt: now,
      );
      final idx = notes.indexWhere((n) => n.id == updated.id);
      if (idx != -1) {
        notes[idx] = updated;
      } else {
        notes.insert(0, updated);
      }
    } else {
      final newNote = NoteModel(
        id: now.toString(), // simple unique id
        title: t,
        description: d,
        updatedAt: now,
      );
      notes.insert(0, newNote);
    }

    await NotesStorage.saveNotes(notes);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Note' : 'New Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
            ),
            child: TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
            ),
            child: TextField(
              controller: _desc,
              minLines: 6,
              maxLines: 12,
              decoration: const InputFieldBorderless().decoration,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tip: Use this for quick daily tasks, reminders, or calculation notes.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class InputFieldBorderless {
  const InputFieldBorderless();

  InputDecoration get decoration => const InputDecoration(
        border: InputBorder.none,
        hintText: 'Description (optional)',
      );
}
