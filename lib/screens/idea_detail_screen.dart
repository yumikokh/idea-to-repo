import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/idea.dart';
import '../providers/app_provider.dart';
import 'idea_form_screen.dart';
import 'create_repo_screen.dart';

class IdeaDetailScreen extends StatelessWidget {
  final Idea idea;

  const IdeaDetailScreen({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイデア詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IdeaFormScreen(idea: idea)),
              ).then((_) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteIdea(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '作成日: ${_formatDate(idea.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (idea.updatedAt != null)
              Text(
                '更新日: ${_formatDate(idea.updatedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 24),
            Text('説明', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(idea.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createRepository(context),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('リポジトリを作成'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _deleteIdea(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('このアイデアを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<AppProvider>().deleteIdea(idea.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  void _createRepository(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateRepoScreen(idea: idea)),
    );
  }
}
