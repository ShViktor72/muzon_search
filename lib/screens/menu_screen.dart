import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
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
        centerTitle: true,
        title: const Text('Меню')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildMenuButton(
                context,
                icon: Icons.folder_open,
                text: 'Выбрать папку для загрузки',
                onPressed: _pickFolder,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.info_outline,
                text: _selectedFolder != null
                    ? 'Текущая папка: ${_selectedFolder!.split('/').last}'
                    : 'Папка не выбрана',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_selectedFolder ?? 'Папка не выбрана'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.info,
                text: 'О программе',
                onPressed: _showAboutDialog,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.favorite,
                text: 'Поддержать проект',
                onPressed: () {
                  Navigator.pushNamed(context, '/donate');
                },
              ),
              const SizedBox(height: 64),
              _buildMenuButton(
                context,
                icon: Icons.home,
                text: 'На главный экран',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.exit_to_app,
                text: 'Выход из приложения',
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О программе'),
        content: const Text(
          'Поиск и скачивание музыки из Инернета\n\n'
          'Разработал: Buktop72\n'
          'v1.4.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поддержать проект'),
        content: const Text(
          'Если приложение оказалось полезным — поддержите разработчика ❤️\n'
          'В будущем тут появится ссылка на донат или карта.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
