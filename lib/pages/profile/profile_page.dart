import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/pages/profile/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;
  String? _id;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state is ProfileLoaded) {
      final profile = (profileBloc.state as ProfileLoaded).profile;
      _nameController = TextEditingController(text: profile.name);
      _emailController = TextEditingController(text: profile.email);
      _avatarUrlController = TextEditingController(text: profile.avatarUrl);
      _id = profile.id.toString(); // Assuming id is an integer
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _avatarUrlController = TextEditingController();
      _id = null;
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 95,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _avatarUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      // Handle any errors here
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStateStatus.updateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Profile updated successfully'),
              ),
            );
          } else if (state.status == ProfileStateStatus.updateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('Profile updated failed'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('ID: $_id', style: TextStyle(fontSize: 16)),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _avatarUrlController,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
                const SizedBox(height: 20),
                if (_imageFile != null)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(_imageFile!.path)),
                      ),
                    ),
                  )
                else if (_avatarUrlController.text.isNotEmpty)
                  _buildAvatarWidget(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Here you can add the logic to update the profile
                    context
                        .read<ProfileBloc>()
                        .add(ProfileUpdateEvent(UserProfile.update(
                          id: int.tryParse(_id ?? '') ?? 1,
                          name: _nameController.text,
                          email: _emailController.text,
                          avatarUrl: _avatarUrlController.text,
                          updatedAt: DateTime.now(),
                        )));
                  },
                  child: const Text('Update Profile'),
                )
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onImageButtonPressed(ImageSource.gallery),
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    final avatarUrl = _avatarUrlController.text;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatarUrl),
          ),
        ),
      );
    } else if (avatarUrl.startsWith("assets/")) {
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: AssetImage(avatarUrl),
      );
    } else {
      var file = File(_avatarUrlController.text);
      var fileImage = FileImage(file);
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: fileImage,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }
}
