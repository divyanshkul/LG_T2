import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/kml_preview_dialog.dart';
import '../widgets/kml_selector_tile.dart';
import '../widgets/action_tile.dart';
import '../widgets/connection_status.dart';
import '../services/connection_service.dart';
import 'connection_screen.dart';
import '../services/lg_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionStateProvider);
    final lgService = LGService(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Controller'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConnectionStatus(isConnected: isConnected),
          ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withBlue(50),
            ],
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ActionTile(
                icon: Icons.image,
                title: 'Display Logo',
                subtitle: 'Show LG logo on left screen',
                color: const Color(0xFF64B5F6),
                onTap: isConnected
                    ? () {
                        lgService.displayLogo(context);
                        print("clicked");
                      }
                    : null),
            KMLSelectorTile(
              onKMLSelected: isConnected
                  ? (kml) {
                      lgService.sendKML(context, kml);
                    }
                  : null,
              onPreviewKML: (kml) {
                showDialog(
                  context: context,
                  builder: (context) => KMLPreviewDialog(kml: kml),
                );
              },
            ),
            ActionTile(
              icon: Icons.cleaning_services,
              title: 'Clean All',
              subtitle: 'Remove logos and KMLs',
              color: const Color(0xFFE57373),
              onTap: isConnected ? () => lgService.cleanAll(context) : null,
            ),
            ActionTile(
              icon: Icons.watch_later_sharp,
              title: 'Set Slaves Refresh',
              subtitle: 'Set duration for slaves',
              color: const Color(0xFF81C784),
              onTap: isConnected ? () => lgService.setRefresh(context) : null,
            ),
            ActionTile(
              icon: Icons.replay,
              title: 'Relaunch LG',
              subtitle: 'Relaunch LG Rig',
              color: const Color(0xFF81C784),
              onTap: isConnected ? () => lgService.relaunchLG(context) : null,
            ),
            ActionTile(
              icon: Icons.power_settings_new,
              title: 'Power Off',
              subtitle: 'Power Off LG Rig',
              color: const Color(0xFF81C784),
              onTap: isConnected ? () => lgService.shutdownLG(context) : null,
            ),
          ],
        ),
      ),
    );
  }
}
