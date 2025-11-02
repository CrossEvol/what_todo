import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/bloc/resource/resource_bloc.dart';
import 'package:flutter_app/models/resource.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ResourceManagePage extends StatefulWidget {
  final int taskId;

  const ResourceManagePage({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  State<ResourceManagePage> createState() => _ResourceManagePageState();
}

class _ResourceManagePageState extends State<ResourceManagePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load resources for this task when the page initializes
    context.read<ResourceBloc>().add(LoadResourcesEvent(widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.manageResources,
        ),
      ),
      body: BlocConsumer<ResourceBloc, ResourceState>(
        listener: (context, state) {
          if (state is ResourceAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload resources after successful addition
            context.read<ResourceBloc>().add(LoadResourcesEvent(widget.taskId));
          } else if (state is ResourceRemoveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload resources after successful removal
            context.read<ResourceBloc>().add(LoadResourcesEvent(widget.taskId));
          } else if (state is ResourceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ResourceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ResourceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ResourceBloc>()
                          .add(LoadResourcesEvent(widget.taskId));
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (state is ResourceLoaded) {
            final resources = state.resources;

            if (resources.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noResourcesAttached,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.tapAddToAttachImages,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return _buildResourceItem(context, resource);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        child: const Icon(Icons.add),
        tooltip: AppLocalizations.of(context)!.addResource,
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourceModel resource) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Dismissible(
        key: Key('resource_${resource.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.red,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.0),
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmationDialog(context, resource);
        },
        onDismissed: (direction) {
          context.read<ResourceBloc>().add(
                RemoveResourceEvent(resource.id, resource.path),
              );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: _buildResourceThumbnail(resource.path),
          title: Text(
            _getResourceFileName(resource.path),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: resource.createTime != null
              ? Text(
                  _formatDateTime(resource.createTime!),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _showFullScreenImage(context, resource),
            tooltip: AppLocalizations.of(context)!.viewFullSize,
          ),
        ),
      ),
    );
  }

  Widget _buildResourceThumbnail(String imagePath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[400],
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getResourceFileName(String path) {
    return path.split('/').last;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, ResourceModel resource) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(
            AppLocalizations.of(context)!.deleteResourceConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.gallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppLocalizations.of(context)!.camera),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce storage usage
      );

      if (image != null) {
        context.read<ResourceBloc>().add(
              AddResourceEvent(widget.taskId, image.path),
            );
      }
    } catch (e) {
      // Let the bloc handle the error by emitting ResourceError state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image from gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress image to reduce storage usage
      );

      if (image != null) {
        context.read<ResourceBloc>().add(
              AddResourceEvent(widget.taskId, image.path),
            );
      }
    } catch (e) {
      // Let the bloc handle the error by emitting ResourceError state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFullScreenImage(BuildContext context, ResourceModel resource) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(resource: resource),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final ResourceModel resource;

  const _FullScreenImageView({
    Key? key,
    required this.resource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _getResourceFileName(resource.path),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(resource.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getResourceFileName(String path) {
    return path.split('/').last;
  }
}
