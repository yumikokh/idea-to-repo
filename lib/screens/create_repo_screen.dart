import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/idea.dart';
import '../models/repository.dart';
import '../providers/app_provider.dart';

class CreateRepoScreen extends StatefulWidget {
  final Idea idea;

  const CreateRepoScreen({super.key, required this.idea});

  @override
  State<CreateRepoScreen> createState() => _CreateRepoScreenState();
}

class _CreateRepoScreenState extends State<CreateRepoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isPrivate = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.idea.title.toLowerCase().replaceAll(' ', '-'),
    );
    _descriptionController = TextEditingController(
      text: widget.idea.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createRepository() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    final provider = context.read<AppProvider>();
    final githubService = provider.githubService;

    final isAuthenticated = await githubService.isAuthenticated();
    if (!isAuthenticated) {
      setState(() {
        _isCreating = false;
      });
      _showMessage('GitHubにログインしてください');
      return;
    }

    final repository = Repository(
      name: _nameController.text,
      description: _descriptionController.text,
      isPrivate: _isPrivate,
      ideaId: widget.idea.id,
    );

    final result = await githubService.createRepository(repository);
    if (result != null) {
      final owner = result['owner']['login'];
      final repoName = result['name'];

      await githubService.createWorkflowFile(owner, repoName);

      if (mounted) {
        _showSuccessDialog(result['html_url']);
      }
    } else {
      _showMessage('リポジトリの作成に失敗しました');
    }

    setState(() {
      _isCreating = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessDialog(String repoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('成功！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('リポジトリが作成されました。'),
              const SizedBox(height: 8),
              const Text('Claude Code Actionsも設定されています。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final uri = Uri.parse(repoUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                if (mounted) {
                  navigator.pop();
                  navigator.pop();
                }
              },
              child: const Text('リポジトリを開く'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('リポジトリを作成')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'リポジトリ名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'リポジトリ名を入力してください';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(value)) {
                    return '英数字、ハイフン、アンダースコアのみ使用できます';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '説明を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('プライベートリポジトリ'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createRepository,
                  child: _isCreating
                      ? const CircularProgressIndicator()
                      : const Text('作成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
