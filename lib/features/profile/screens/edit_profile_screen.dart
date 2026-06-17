import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

const kPrimaryColor = Color(0xFF3D3AC1);
const kBackgroundColor = Color(0xFFF0F0F7);
const kCardColor = Colors.white;
const kTextDark = Color(0xFF1A1A2E);
const kTextGrey = Color(0xFF8A8A9A);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _studentIdController = TextEditingController();
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _studentIdController.text = profile['studentId'] ?? '';
        _existingImageUrl = profile['profileImageUrl'];
        _profileLoaded = true;
      });
    } else {
      setState(() => _profileLoaded = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  ImageProvider? _getImageProvider() {
    if (_pickedImage != null) return FileImage(_pickedImage!);
    if (_existingImageUrl != null) {
      if (_existingImageUrl!.startsWith('data:image')) {
        final base64Data = _existingImageUrl!.split(',')[1];
        return MemoryImage(base64Decode(base64Data));
      }
      return NetworkImage(_existingImageUrl!);
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await repo.uploadProfileImage(_pickedImage!);
      }
      await repo.updateProfile({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
      });
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextGrey, fontSize: 13),
      prefixIcon: Icon(icon, color: kTextGrey, size: 20),
      filled: true,
      fillColor: kBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: !_profileLoaded
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor:
                                  kPrimaryColor.withOpacity(0.15),
                              backgroundImage: _getImageProvider(),
                              child: _getImageProvider() == null
                                  ? const Icon(Icons.person_rounded,
                                      size: 56, color: kPrimaryColor)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Tap to change photo',
                          style:
                              TextStyle(color: kTextGrey, fontSize: 12)),
                    ),
                    const SizedBox(height: 32),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Full Name',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kTextDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                                'Enter your full name',
                                Icons.person_outline),
                            validator: (v) =>
                                v!.isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 18),

                          const Text('Student ID',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kTextDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _studentIdController,
                            decoration: _inputDecoration(
                                'e.g. 2021812345',
                                Icons.badge_outlined),
                          ),
                          const SizedBox(height: 18),

                          const Text('Bio',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kTextDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _bioController,
                            decoration: _inputDecoration(
                                'Tell us about yourself',
                                Icons.info_outline),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}