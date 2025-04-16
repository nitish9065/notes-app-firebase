import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/core/wdgets/are_you_sure_dialog.dart';
import 'package:notes_app/features/home/data/provider.dart';
import 'package:notes_app/features/home/model/note_content_search_model.dart';
import 'package:notes_app/features/home/widgets/in_note_search_bar.dart';
import 'package:notes_app/features/home/widgets/user_list_view.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final bool lockActions;
  const NoteEditorScreen(
      {required this.noteId, required this.lockActions, super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _searchController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _searchFocus = FocusNode();
    _loadExistingNote();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _isSearching = ref.watch(inNoteSearchProvider);
    final searchState = ref.watch(noteContentSearchProvider);
    final content = searchState.highlightedContent.isNotEmpty
        ? searchState.highlightedContent
        : [
            TextSpan(
              text: _contentController.text.trim(),
            )
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.noteId == null ? 'New Note' : 'Edit Note',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: _showSearchBar,
            icon: Icon(
              !_isSearching ? Icons.search : Icons.cancel,
            ),
          ),
          if (!widget.lockActions) ...[
            if (!_isSearching) ...[
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  await _saveNote();
                  context.pop();
                },
              ),
              if (widget.noteId != null)
                IconButton(
                  onPressed: () async {
                    await _deleteNote();
                  },
                  icon: const Icon(Icons.delete),
                ),
            ]
          ]
        ],
      ),
      body: _isSearching
          ? Column(
              children: [
                if (_isSearching)
                  InNoteSearchBar(
                    _searchController,
                    _searchFocus,
                    _contentController.text,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: content,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      readOnly: widget.lockActions,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      onTap: () async {
                        if (widget.lockActions) return;
                        await showModalBottomSheet(
                          context: context,
                          barrierLabel: 'Select Users to share',
                          backgroundColor: Colors.white,
                          showDragHandle: true,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Select Users to share :',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const Divider(),
                                const Expanded(child: UserListView()),
                              ],
                            );
                          },
                        );
                      },
                      tileColor: Colors.green.shade100,
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      visualDensity:
                          const VisualDensity(horizontal: 4, vertical: -2),
                      title: Consumer(
                        builder: (context, ref, child) {
                          final selectedUserIdList =
                              ref.watch(selectedUserIdProvider);
                          return Text(
                            selectedUserIdList.isEmpty
                                ? 'Share this note'
                                : 'Sharing with ${selectedUserIdList.length} users, share with more',
                          );
                        },
                      ),
                      trailing: const Icon(Icons.share_rounded),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: widget.lockActions,
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          alignLabelWithHint: true,
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        expands: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(notesRepositoryProvider).saveNote(
          title: _titleController.text,
          content: _contentController.text,
          userId: ref.read(userProvider)!.uid,
          sharedUsers: ref.read(selectedUserIdProvider),
          noteId: widget.noteId,
        );
  }

  Future<void> _deleteNote() async {
    final shouldDelete = await showSureDialog(
      title: 'Are you sure, you want to delete this note?',
      content: 'Once deleted, this note can not be recovered!',
      context: context,
    );
    if (shouldDelete ?? false) {
      await ref.read(notesRepositoryProvider).deleteNote(widget.noteId!);
      context.pop();
    }
  }

  Future<void> _loadExistingNote() async {
    if (widget.noteId == null) return;

    final note =
        await ref.read(notesRepositoryProvider).getNote(widget.noteId!);
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      ref.read(selectedUserIdProvider.notifier).addAll(note.sharedWith);
    }
  }

  void _showSearchBar() {
    ref.read(inNoteSearchProvider.notifier).update(
          (state) => !state,
        );
    if (ref.read(inNoteSearchProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }
}
