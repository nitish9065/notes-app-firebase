import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/home/model/note.dart';
import 'package:notes_app/features/home/widgets/note_tile.dart';

class NoteSearchDelegate extends SearchDelegate<String> {
  final AsyncValue<List<Note>> notes;

  NoteSearchDelegate(this.notes);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    return notes.when(
      data: (notes) => ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 10.0,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          if (note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase())) {
            return NoteTile(note: note);
          }
          return const SizedBox.shrink();
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_back));
  }
}
