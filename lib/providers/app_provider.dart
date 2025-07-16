import 'package:flutter/material.dart';
import '../models/idea.dart';
import '../services/database_service.dart';
import '../services/github_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final GitHubService _githubService = GitHubService();
  
  List<Idea> _ideas = [];
  bool _isLoading = false;
  String? _error;

  List<Idea> get ideas => _ideas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GitHubService get githubService => _githubService;

  Future<void> loadIdeas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ideas = await _databaseService.getIdeas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIdea(Idea idea) async {
    _error = null;
    try {
      await _databaseService.insertIdea(idea);
      await loadIdeas();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateIdea(Idea idea) async {
    _error = null;
    try {
      await _databaseService.updateIdea(idea);
      await loadIdeas();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteIdea(String id) async {
    _error = null;
    try {
      await _databaseService.deleteIdea(id);
      await loadIdeas();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}