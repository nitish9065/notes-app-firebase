import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/home/widgets/note_listing.dart';
import 'package:notes_app/features/user/data/provider.dart';

class UserSharedNoteScreen extends ConsumerWidget {
  const UserSharedNoteScreen(this.showSharedBy, {super.key});
  final bool showSharedBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          showSharedBy ? 'Shared BY You' : 'Shared With You',
        ),
      ),
      body: ref.watch(userSharedNoteListProvider(showSharedBy)).when(
            data: (data) => NoteListing(
              notes: data,
              lockActions: !showSharedBy,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorWidget(error.toString()),
          ),
    );
  }
}
