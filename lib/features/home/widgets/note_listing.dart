import 'package:flutter/material.dart';
import 'package:notes_app/features/home/model/note.dart';

import 'note_tile.dart';

class NoteListing extends StatelessWidget {
  const NoteListing({super.key, required this.notes, this.lockActions = false});
  final List<Note> notes;
  final bool lockActions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      separatorBuilder: (context, index) => const SizedBox(
        height: 10.0,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteTile(
          note: note,
          lockActions: lockActions,
        );
      },
    );
  }
}
