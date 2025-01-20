import 'package:flutter/material.dart';
import '../models/kml_file.dart';
import '../data/sample_kmls.dart';

class KMLSelectorTile extends StatelessWidget {
  final void Function(KMLFile)? onKMLSelected;
  final void Function(KMLFile) onPreviewKML;

  const KMLSelectorTile({
    super.key,
    required this.onKMLSelected,
    required this.onPreviewKML,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.public,
              size: 48,
              color: Color(0xFF81C784),
            ),
            const SizedBox(height: 8),
            Text(
              'Send KML',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PopupMenuButton<KMLFile>(
              enabled: onKMLSelected != null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: onKMLSelected != null
                        ? Colors.grey.shade600
                        : Colors.grey.shade800,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select KML',
                      style: TextStyle(
                        color:
                            onKMLSelected != null ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down,
                      color: onKMLSelected != null ? Colors.white : Colors.grey,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => sampleKMLs.map((kml) {
                return PopupMenuItem(
                  value: kml,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kml.name),
                            Text(
                              kml.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.preview),
                        onPressed: () {
                          Navigator.pop(context);
                          onPreviewKML(kml);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              onSelected: onKMLSelected,
            ),
          ],
        ),
      ),
    );
  }
}
