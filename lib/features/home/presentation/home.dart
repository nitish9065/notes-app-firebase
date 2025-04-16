import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/features/home/data/provider.dart';
import 'package:notes_app/features/home/model/note.dart';
import 'package:notes_app/features/home/widgets/note_listing.dart';
import 'package:notes_app/features/home/widgets/note_search_delegate.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          'My Notes',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: NoteSearchDelegate(notes),
            ),
          ),
          ref.watch(appUserStream).when(
                data: (data) => InkWell(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data.photoUrl ?? ''),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    error.toString(),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          const SizedBox(
            width: 10.0,
          )
        ],
      ),
      body: notes.when(
        data: (notes) => _NotesListView(notes: notes, query: searchQuery),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorWidget(error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/home/${null}'),
      ),
    );
  }
}

class _NotesListView extends StatelessWidget {
  final List<Note> notes;
  final String query;

  const _NotesListView({required this.notes, required this.query});

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return NoteListing(
      notes: filteredNotes,
    );
  }
}
