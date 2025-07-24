import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UploadAvatarTest extends StatefulWidget {
  const UploadAvatarTest({super.key});

  @override
  State<UploadAvatarTest> createState() => _UploadAvatarTestState();
}

class _UploadAvatarTestState extends State<UploadAvatarTest> {
  File? _imageFile;
  String? _downloadUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final fileName = path.basename(_imageFile!.path);
    final ref = FirebaseStorage.instance.ref().child('avatars/$fileName');

    final uploadTask = await ref.putFile(_imageFile!);
    final url = await uploadTask.ref.getDownloadURL();

    setState(() {
      _downloadUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Avatar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 150),
            if (_downloadUrl != null)
              Text('URL:\n$_downloadUrl', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Galería'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
