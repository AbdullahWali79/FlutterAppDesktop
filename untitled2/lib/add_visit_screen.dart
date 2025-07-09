import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'visit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddVisitScreen extends StatefulWidget {
  final int patientId;
  final Visit? visit;
  const AddVisitScreen({Key? key, required this.patientId, this.visit}) : super(key: key);

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosisController;
  late TextEditingController _commentInputController;
  List<String> _comments = [];
  bool _isSaving = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(text: widget.visit?.diagnosis ?? '');
    _commentInputController = TextEditingController();
    if (widget.visit?.comments != null && widget.visit!.comments.isNotEmpty) {
      _comments = widget.visit!.comments.split('\n');
    }
    _imagePath = widget.visit?.imagePath;
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _commentInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _addComment() {
    final text = _commentInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.add(text);
        _commentInputController.clear();
      });
    }
  }

  void _removeComment(int index) {
    setState(() {
      _comments.removeAt(index);
    });
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_comments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one comment.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final visit = Visit(
      id: widget.visit?.id,
      patientId: widget.patientId,
      diagnosis: _diagnosisController.text.trim(),
      comments: _comments.join('\n'),
      dateTime: widget.visit?.dateTime ?? DateTime.now(),
      imagePath: _imagePath,
    );
    try {
      if (widget.visit == null) {
        final id = await DatabaseHelper().insertVisit(visit);
        if (id > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit added successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add visit.')),
          );
        }
      } else {
        final count = await DatabaseHelper().updateVisit(visit);
        if (count > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update visit.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.visit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Visit' : 'Add Visit')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter diagnosis' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _commentInputController,
                        decoration: const InputDecoration(labelText: 'Add Comment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addComment,
                      child: const Icon(Icons.add_comment),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_comments.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Comments:', style: TextStyle(color: Colors.yellow)),
                        ..._comments.asMap().entries.map((entry) => ListTile(
                          title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeComment(entry.key),
                          ),
                        )),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Add Image'),
                    ),
                    const SizedBox(width: 16),
                    if (_imagePath != null)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveVisit,
                        child: Text(isEdit ? 'Update' : 'Save'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 