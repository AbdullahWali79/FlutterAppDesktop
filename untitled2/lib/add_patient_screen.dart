import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'patient.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class AddPatientScreen extends StatefulWidget {
  final Patient? patient;
  const AddPatientScreen({Key? key, this.patient}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isSaving = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _addressController = TextEditingController(text: widget.patient?.address ?? '');
    _phoneController = TextEditingController(text: widget.patient?.phone ?? '');
    _imagePath = widget.patient?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.yellow,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (cropped != null) {
        setState(() {
          _imagePath = cropped.path;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.yellow,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (cropped != null) {
        setState(() {
          _imagePath = cropped.path;
        });
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final patient = Patient(
      id: widget.patient?.id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      imagePath: _imagePath,
    );
    if (widget.patient == null) {
      await DatabaseHelper().insertPatient(patient);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added successfully!')),
        );
      }
    } else {
      await DatabaseHelper().updatePatient(patient);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient updated successfully!')),
        );
      }
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
    final name = _nameController.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Patient' : 'Add Patient')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.yellow[700],
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '',
                          style: const TextStyle(fontSize: 40, color: Colors.black),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value == null || value.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _savePatient,
                      child: Text(isEdit ? 'Update' : 'Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 