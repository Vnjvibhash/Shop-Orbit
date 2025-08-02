import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/widgets/common/custom_app_bar.dart';

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

  List<TextEditingController> _addressControllers = [];

  @override
  void dispose() {
    for (final c in _addressControllers) {
      c.dispose();
    }
    super.dispose();
  }

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

  void _initializeAddressControllers(List<String> addresses) {
    _addressControllers = addresses
        .map((addr) => TextEditingController(text: addr))
        .toList();
    if (_addressControllers.isEmpty) {
      _addressControllers.add(TextEditingController());
    }
  }

  void _addAddressField() {
    setState(() {
      _addressControllers.add(TextEditingController());
    });
  }

  void _removeAddressField(int index) {
    setState(() {
      _addressControllers[index].dispose();
      _addressControllers.removeAt(index);
    });
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    // Gather all addresses that are not empty
    List<String> updatedAddresses = _addressControllers
        .map((controller) => controller.text.trim())
        .where((addr) => addr.isNotEmpty)
        .toList();

    try {
      // Update Firestore or your backend here:
      await authProvider.updateUserProfile(
        name: _name!.trim(),
        email: _email!.trim(),
        profileImage: _imageFile,
        addresses: updatedAddresses,
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

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        // Initialize address controllers if empty and if user has addresses:
        if (_addressControllers.isEmpty && user != null) {
          _initializeAddressControllers(user.addresses);
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Profile',
            showLogout: true,
          ),
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
                                          (user?.profileImage?.isNotEmpty ??
                                              false))
                                    ? NetworkImage(user!.profileImage!)
                                    : null,
                                child:
                                    _imageFile == null &&
                                        (user?.profileImage == null ||
                                            (user?.profileImage?.isNotEmpty !=
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
                        const SizedBox(height: 24),
                        Text(
                          'Addresses',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        // List of address input fields
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _addressControllers.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _addressControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Address ${index + 1}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_addressControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeAddressField(index),
                                  ),
                              ],
                            );
                          },
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addAddressField,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Address'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Display createdAt and updatedAt (read-only)
                        if (user != null) ...[
                          Text(
                            'Account Created: ${formatDateTime(user.createdAt)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last Updated: ${formatDateTime(user.updatedAt)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                        ],

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
