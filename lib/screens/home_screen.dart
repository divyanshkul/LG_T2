import 'package:flutter/material.dart';
import '../widgets/action_tile.dart';
import 'connection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Controller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: const [
          ActionTile(
            icon: Icons.image,
            title: 'Display Logo',
            subtitle: 'Show LG logo on left screen',
            color: Colors.blue,
          ),
          ActionTile(
            icon: Icons.file_present,
            title: 'Send KML 1',
            subtitle: 'Load first KML file',
            color: Colors.green,
          ),
          ActionTile(
            icon: Icons.cleaning_services,
            title: 'Clean All',
            subtitle: 'Remove logos and KMLs',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
