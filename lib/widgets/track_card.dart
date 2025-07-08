import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;

  const TrackCard({super.key, required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('${track.artist} — ${track.title}'),
        onTap: onTap,
      ),
    );
  }
}
