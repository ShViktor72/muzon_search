import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/settings_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _loadFolder();
  }

  Future<void> _loadFolder() async {
    final folder = await SettingsService.getFolderPath();
    setState(() {
      _selectedFolder = folder;
    });
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await SettingsService.saveFolderPath(selectedDirectory);
      setState(() {
        _selectedFolder = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFolder,
              child: const Text('Выбрать папку для загрузки'),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFolder != null
                  ? 'Выбранная папка:\n$_selectedFolder'
                  : 'Папка не выбрана',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

