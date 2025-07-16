import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<AppProvider>();
    final githubService = provider.githubService;

    final user = await githubService.getUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _saveToken() async {
    if (_tokenController.text.isEmpty) {
      _showMessage('トークンを入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<AppProvider>();
    final githubService = provider.githubService;

    await githubService.saveToken(_tokenController.text);
    _tokenController.clear();
    await _loadUserInfo();

    _showMessage('トークンが保存されました');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openGitHubSettings() async {
    final uri = Uri.parse('https://github.com/settings/tokens/new');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_user != null) ...[
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(_user!['avatar_url']),
                        ),
                        title: Text(_user!['name'] ?? _user!['login']),
                        subtitle: Text('@${_user!['login']}'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'GitHub Personal Access Token',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'リポジトリを作成するには、GitHubのPersonal Access Tokenが必要です。',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Personal Access Token',
                      border: OutlineInputBorder(),
                      hintText: 'ghp_xxxxxxxxxxxx',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveToken,
                          child: const Text('保存'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _openGitHubSettings,
                          child: const Text('トークンを作成'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '必要な権限:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• repo (フルアクセス)'),
                  const Text('• workflow (ワークフローの作成)'),
                ],
              ),
            ),
    );
  }
}