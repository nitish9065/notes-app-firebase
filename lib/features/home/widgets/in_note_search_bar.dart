import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/home/model/note_content_search_model.dart';

class InNoteSearchBar extends ConsumerWidget {
  const InNoteSearchBar(this.searchController, this.searchFocus, this.content,
      {super.key});
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final String content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: searchFocus,
              decoration: const InputDecoration(
                hintText: 'Search in note...',
                border: InputBorder.none,
              ),
              onChanged: (query) => ref
                  .read(noteContentSearchProvider.notifier)
                  .search(query, content),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final searchState = ref.watch(noteContentSearchProvider);

              return Text(
                  '${searchState.currentMatchIndex + 1}/${searchState.totalMatches}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () =>
                ref.read(noteContentSearchProvider.notifier).navigateMatch(-1),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () =>
                ref.read(noteContentSearchProvider.notifier).navigateMatch(1),
          ),
        ],
      ),
    );
  }
}
