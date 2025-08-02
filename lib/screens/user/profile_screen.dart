import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Adjust these imports according to your project structure
import 'package:shoporbit/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      // You'd update Firestore or your backend here:
      await authProvider.updateUserProfile(
        name: _name!.trim(),
        email: _email!.trim(),
        imageFile: _imageFile,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (user?.profileImage != null &&
                                          user!.profileImage!.isNotEmpty)
                                    ? NetworkImage(user.profileImage!)
                                    : null,
                                child:
                                    _imageFile == null &&
                                        (user?.profileImage == null ||
                                            (user
                                                    ?.profileImage
                                                    ?.isNotEmpty !=
                                                true))
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          initialValue: user?.name ?? '',
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter your name'
                              : null,
                          onSaved: (val) => _name = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: user?.email ?? '',
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter your email'
                              : null,
                          onSaved: (val) => _email = val,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => _saveProfile(authProvider),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
