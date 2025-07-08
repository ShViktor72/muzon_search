import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/settings_service.dart';
import '../services/download_service.dart';
import 'package:path/path.dart' as p;
import '../widgets/track_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Track {
  final String artist;
  final String title;
  final String url;

  Track({required this.artist, required this.title, required this.url});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      artist: json['artist'],
      title: json['title'],
      url: json['url'],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Track> _tracks = [];
  bool _isLoading = false;

  Future<void> _searchTracks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _tracks.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.214:5000/api/search?q=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _tracks = data.map((item) => Track.fromJson(item)).toList();
        });
      } else {
        throw Exception('Ошибка сервера');
      }
    } catch (e) {
      debugPrint('Ошибка: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _downloadTrack(Track track) async {
    final folderPath = await SettingsService.getFolderPath();

    if (folderPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сначала выберите папку для загрузки в меню'),
          ),
        );
      }
      return;
    }

    final fileName = '${track.artist}_${track.title}.mp3'.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Скачивание: ${track.artist} — ${track.title}'),
          ),
        );
      }

      await DownloadService.downloadFile(
        track.url,
        folderPath,
        fileName,
        onProgress: (received, total) {
          if (total != -1) {
            final percent = (received / total * 100).toStringAsFixed(0);
            debugPrint('Скачивание ${track.title}: $percent%');
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Готово: ${track.artist} — ${track.title}')),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при скачивании: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при скачивании ${track.title}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Музыка Загрузчик'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Введите запрос',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchTracks(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchTracks,
                  child: const Text('Поиск'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_tracks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Нет результатов'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  return TrackCard(
                    track: track,
                    onTap: () {
                      _downloadTrack(track); // тут у нас метод из HomeScreen
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
