import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../viewModel/auth_view_model.dart';
import '../../../../viewModel/user_view_model.dart';

class ProfileEditScreen extends StatefulWidget {
  final String? id;
  final String? token;
  ProfileEditScreen({super.key, this.id, this.token});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    _nameController.text = authViewModel.user?.name ?? 'Unknown User';
    _bioController.text = authViewModel.user?.bio ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (widget.id == null || authViewModel.user?.id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur non authentifié')),
                );
                return;
              }

              bool updateSuccess = await userViewModel.updateUserProfile(
                widget.id!,
                {
                  'name': _nameController.text,
                  'bio': _bioController.text,
                },
                authViewModel.user?.token, // Passer token nullable
              );

              if (updateSuccess && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
                Navigator.pop(context);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(userViewModel.errorMessage ?? 'An unknown error occurred')),
                );
              }

              if (_image != null) {
                bool uploadSuccess = await userViewModel.uploadProfilePicture(
                  authViewModel.user!.id!,
                  _image!,
                  authViewModel.user?.token, // Passer token nullable
                );

                if (uploadSuccess && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile picture updated successfully')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(userViewModel.errorMessage ?? 'Failed to update profile picture')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (authViewModel.user?.profilePicture?.url != null)
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: NetworkImage(authViewModel.user!.profilePicture!.url!),
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    onPressed: () async {
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _image = File(pickedFile.path);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: "Bio"),
          ),
        ],
      ),
    );
  }
}