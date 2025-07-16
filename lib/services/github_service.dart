import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/repository.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _tokenKey = 'github_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> createRepository(Repository repo) async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/user/repos'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: json.encode(repo.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<bool> createWorkflowFile(String owner, String repo) async {
    final token = await getToken();
    if (token == null) return false;

    final workflowContent = base64Encode(utf8.encode(_claudeWorkflowYaml));

    final response = await http.put(
      Uri.parse('$_baseUrl/repos/$owner/$repo/contents/.github/workflows/claude.yml'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message': 'Add Claude Code workflow',
        'content': workflowContent,
      }),
    );

    return response.statusCode == 201;
  }

  static const String _claudeWorkflowYaml = '''
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude:
    if: \${{ github.event.comment.body == '@claude' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic-api-key: \${{ secrets.ANTHROPIC_API_KEY }}
''';
}