import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/idea.dart';

class IdeaFormScreen extends StatefulWidget {
  final Idea? idea;

  const IdeaFormScreen({super.key, this.idea});

  @override
  State<IdeaFormScreen> createState() => _IdeaFormScreenState();
}

class _IdeaFormScreenState extends State<IdeaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.idea?.title ?? '');
    _descriptionController = TextEditingController(text: widget.idea?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveIdea() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      
      if (widget.idea == null) {
        final newIdea = Idea(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
        );
        await provider.addIdea(newIdea);
      } else {
        final updatedIdea = Idea(
          id: widget.idea!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          createdAt: widget.idea!.createdAt,
          updatedAt: DateTime.now(),
        );
        await provider.updateIdea(updatedIdea);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.idea == null ? '新しいアイデア' : 'アイデアを編集'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
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
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '説明を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveIdea,
                child: Text(widget.idea == null ? '作成' : '更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}