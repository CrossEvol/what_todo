import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/github_cubit.dart';
import '../../models/github_config.dart';
import '../../services/qr_code_service.dart';
import '../../utils/permission_handler.dart';
import '../../utils/logger_util.dart';

class GitHubConfigPage extends StatefulWidget {
  const GitHubConfigPage({super.key});

  @override
  State<GitHubConfigPage> createState() => _GitHubConfigPageState();
}

class _GitHubConfigPageState extends State<GitHubConfigPage> {
  late TextEditingController _tokenController;
  late TextEditingController _ownerController;
  late TextEditingController _repoController;
  late TextEditingController _pathPrefixController;
  late TextEditingController _branchController;
  
  final _formKey = GlobalKey<FormState>();
  final _qrCodeService = QRCodeService();

  @override
  void initState() {
    super.initState();
    final currentConfig = context.read<GitHubCubit>().state;
    _tokenController = TextEditingController(text: currentConfig.token);
    _ownerController = TextEditingController(text: currentConfig.owner);
    _repoController = TextEditingController(text: currentConfig.repo);
    _pathPrefixController = TextEditingController(text: currentConfig.pathPrefix);
    _branchController = TextEditingController(text: currentConfig.branch);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    _pathPrefixController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final config = GitHubConfig(
        token: _tokenController.text.trim(),
        owner: _ownerController.text.trim(),
        repo: _repoController.text.trim(),
        pathPrefix: _pathPrefixController.text.trim(),
        branch: _branchController.text.trim(),
      );
      
      context.read<GitHubCubit>().updateConfig(config);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('GitHub configuration saved successfully'),
        ),
      );
      
      context.pop();
    }
  }

  void _showQRScanningInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanning'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To quickly import GitHub configuration from another device:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Generate a QR code on your computer or another device'),
              SizedBox(height: 8),
              Text('2. Grant camera permission on this device'),
              SizedBox(height: 8),
              Text('3. Scan the QR code to auto-fill credentials'),
              SizedBox(height: 12),
              Text(
                'This saves you from manually copying and pasting configuration between devices.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _scanQRCode();
            },
            child: const Text('Understood, Go Scan'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    try {
      // Check and request camera permission
      final hasPermission = await PermissionHandlerService.instance
          .checkAndRequestCameraPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Camera permission is required to scan QR codes'),
            ),
          );
        }
        return;
      }

      // Scan QR code
      final qrData = await _qrCodeService.scanQRCode();
      
      if (qrData == null) {
        // Scan was cancelled or failed
        return;
      }

      // Parse QR data
      try {
        final config = _qrCodeService.parseQRData(qrData);
        
        // Populate form fields
        setState(() {
          _tokenController.text = config.token;
          _ownerController.text = config.owner;
          _repoController.text = config.repo;
          _pathPrefixController.text = config.pathPrefix;
          _branchController.text = config.branch;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('QR code scanned successfully'),
            ),
          );
        }
      } catch (e) {
        logger.error('Failed to parse QR code: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Invalid QR code format'),
            ),
          );
        }
      }
    } catch (e) {
      logger.error('Error scanning QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error scanning QR code: $e'),
          ),
        );
      }
    }
  }

  void _generateQRCode() {
    final config = GitHubConfig(
      token: _tokenController.text.trim(),
      owner: _ownerController.text.trim(),
      repo: _repoController.text.trim(),
      pathPrefix: _pathPrefixController.text.trim(),
      branch: _branchController.text.trim(),
    );

    // Navigate to QR display page
    context.push('/github_qr_display', extra: config);
  }

  void _copyToClipboard() {
    final config = GitHubConfig(
      token: _tokenController.text.trim(),
      owner: _ownerController.text.trim(),
      repo: _repoController.text.trim(),
      pathPrefix: _pathPrefixController.text.trim(),
      branch: _branchController.text.trim(),
    );

    final jsonString = jsonEncode(config.toMap());
    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Configuration copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Configuration'),
        actions: [
          IconButton(
            icon: const Icon(IconData(0xe685, fontFamily: 'iconfont')),
            onPressed: _showQRScanningInstructions,
            tooltip: 'QR Scanning Instructions',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Configure your GitHub repository for backup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Personal Access Token',
                hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                border: OutlineInputBorder(),
                helperText: 'GitHub personal access token with repo permissions',
              ),
              maxLines: 3,
              minLines: 1,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Token is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Repository Owner',
                hintText: 'username or organization',
                border: OutlineInputBorder(),
                helperText: 'GitHub username or organization name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Owner is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repoController,
              decoration: const InputDecoration(
                labelText: 'Repository Name',
                hintText: 'my-backup-repo',
                border: OutlineInputBorder(),
                helperText: 'Name of the repository for backups',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Repository name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pathPrefixController,
              decoration: const InputDecoration(
                labelText: 'Path Prefix',
                hintText: '/ or backups/',
                border: OutlineInputBorder(),
                helperText: 'Optional path prefix for backup files',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branchController,
              decoration: const InputDecoration(
                labelText: 'Branch',
                hintText: 'main or master',
                border: OutlineInputBorder(),
                helperText: 'Branch name for backups',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Branch is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Configuration',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'qr_generate',
              onPressed: _generateQRCode,
              tooltip: 'Generate QR Code',
              child: const Icon(Icons.document_scanner_sharp),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'copy_clipboard',
              onPressed: _copyToClipboard,
              tooltip: 'Copy to Clipboard',
              child: const Icon(Icons.content_copy),
            ),
          ],
        ),
      ),
    );
  }
}
