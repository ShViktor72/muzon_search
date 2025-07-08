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
  List<DownloadStatus> _downloads = [];

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

    final status = DownloadStatus(track: track);
    setState(() {
      _downloads.add(status);
    });

    try {
      await DownloadService.downloadFile(
        track.url,
        folderPath,
        fileName,
        onProgress: (received, total) {
          if (total != -1) {
            final percent = (received / total * 100);
            debugPrint(
              'Скачивание ${track.title}: ${percent.toStringAsFixed(0)}%',
            );

            setState(() {
              status.progress = percent;
            });
          }
        },
      );

      setState(() {
        _downloads.remove(status);
      });
    } catch (e) {
      debugPrint('Ошибка при скачивании: $e');

      setState(() {
        status.isError = true;
      });

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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/ic_launcher.png', width: 32, height: 32),
        ),
        centerTitle: true,
        title: const Text('Pirate Tunes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Поле поиска на всю ширину с иконкой очистки
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Название трека и/или исполнителя',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // чтобы показывать/убирать иконку очистки
                  },
                  onSubmitted: (_) => _searchTracks(),
                ),
                const SizedBox(height: 12),

                // Кнопка поиска на всю ширину
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _searchTracks,
                    child: const Text('Поиск', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),

                // Результаты поиска
                if (_tracks.isEmpty)
                  const Text('Введите запрос и нажмите Поиск')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        final track = _tracks[index];
                        return TrackCard(
                          track: track,
                          onTap: () {
                            _downloadTrack(track);
                          },
                        );
                      },
                    ),
                  ),

                // Прогресс загрузок
                if (_downloads.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: _downloads.map((d) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d.track.artist} — ${d.track.title}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: d.isError ? null : (d.progress / 100),
                              color: d.isError ? Colors.red : Colors.green,
                              backgroundColor: Colors.grey[300],
                              minHeight: 6,
                            ),
                            const SizedBox(height: 6),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Анимация загрузки поверх всего
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class DownloadStatus {
  final Track track;
  double progress;
  bool isCompleted;
  bool isError;

  DownloadStatus({
    required this.track,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isError = false,
  });
}
