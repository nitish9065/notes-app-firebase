import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/core/wdgets/are_you_sure_dialog.dart';
import 'package:notes_app/features/home/data/provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showSureDialog(
                title: 'Are you sure, you want to logout?',
                content: 'To access your notes, you have to log in again!',
                context: context,
              );
              if (shouldLogout ?? false) {
                await ref.read(authProvider).signOut();
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ref.watch(appUserStream).when(
                  data: (data) => Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(data.photoUrl ?? ''),
                          radius: 56,
                        ),
                        Text(
                          data.displayName ?? 'Unknown',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          data.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
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
              height: 16.0,
            ),
            SizedBox(
              height: 300,
              child: ref.watch(noteCountStatsProvider).when(
                    data: (data) => GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      children: [
                        CardComponent(
                          title: data['totalNotes']?.toString() ?? '0',
                          content: 'Notes created by you!',
                          onTap: () => context.pop(),
                        ),
                        CardComponent(
                          title: data['sharedByUser']?.toString() ?? '0',
                          content: 'Notes shared by you!',
                          onTap: () {
                            context.push('/profile/note',
                                extra: {'showShared': true});
                          },
                        ),
                        CardComponent(
                          title: data['sharedWithUser']?.toString() ?? '0',
                          content: 'Notes shared with you!',
                          onTap: () {
                            context.push('/profile/note',
                                extra: {'showShared': false});
                          },
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Text('Error: ${error.toString()}'),
                  ),
            )
          ],
        ),
      ),
    );
  }
}

class CardComponent extends StatelessWidget {
  const CardComponent(
      {super.key,
      required this.title,
      required this.content,
      required this.onTap});
  final String title, content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        width: width / 2,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              content,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}
