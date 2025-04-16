import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showSureDialog({
  required String title,
  required String content,
  required BuildContext context,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text('Ok'),
        )
      ],
    ),
  );
}
