import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/home/model/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.lockActions = false,
  });
  final Note note;
  final bool lockActions;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onTap: () {
        context.push('/home/${note.id}', extra: {'lockAction': lockActions});
      },
      title: Text(
        note.title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: Text(
        note.content,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 2,
      ),
    );
  }
}
