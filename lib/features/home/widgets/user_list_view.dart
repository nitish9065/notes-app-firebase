import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/home/data/provider.dart';

class UserListView extends ConsumerWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListAsync = ref.watch(userListProvider);
    return userListAsync.when(
      data: (data) => ListView.separated(
          itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data[index].photoUrl ?? ''),
                ),
                title: Text(data[index].displayName ?? 'Unknown'),
                trailing: CheckBoxConsumer(data[index].uid),
              ),
          separatorBuilder: (context, index) => const Divider(
                color: Colors.black12,
                thickness: 0.25,
              ),
          itemCount: data.length),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class CheckBoxConsumer extends ConsumerWidget {
  const CheckBoxConsumer(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedList = ref.watch(selectedUserIdProvider);
    return Checkbox(
      value: selectedList.contains(id),
      activeColor: Colors.deepPurple,
      onChanged: (isSelected) {
        if (!ref.read(selectedUserIdProvider.notifier).exists(id)) {
          ref.read(selectedUserIdProvider.notifier).add(id);
        } else {
          ref.read(selectedUserIdProvider.notifier).remove(id);
        }
      },
    );
  }
}
