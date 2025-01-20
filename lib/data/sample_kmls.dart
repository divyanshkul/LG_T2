import 'package:flutter/material.dart';
import '../models/kml_file.dart';

const sampleKMLs = [
  KMLFile(
    name: 'Tour of Cities',
    description: 'A tour through major world cities',
    content: '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>City Tour</name>
    <!-- KML content here -->
  </Document>
</kml>''',
  ),
  KMLFile(
    name: 'Natural Wonders',
    description: 'Explore amazing natural landmarks',
    content: '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Natural Wonders</name>
    <!-- KML content here -->
  </Document>
</kml>''',
  ),
];
