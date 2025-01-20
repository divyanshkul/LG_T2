import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:lg_t2/models/kml_file.dart';
import 'connection_service.dart';

class LGService {
  final WidgetRef ref;

  LGService(this.ref);

  _getClient(BuildContext context) {
    final client = ref.read(sshClientProvider);
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to LG')),
      );
      throw Exception('Not connected to LG');
    }
    return client;
  }

  int getLogoScreen() {
    const screenAmount = 3;
    return (screenAmount / 2).floor() + 2;
  }

  Future<void> displayLogo(BuildContext context) async {
    try {
      final client = _getClient(context);
      final logoScreen = getLogoScreen();

      const String logoKml = '''<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
            <Document id="logo">
                <name>Smart City Dashboard</name>
                    <Folder>
                          <name>Splash Screen</name>
                          <ScreenOverlay>
                              <name>Logo</name>
                              <Icon>
                                  <href>https://raw.githubusercontent.com/Prayag-X/Smart-City-Dashboard/main/assets/images/splash.png</href>
                              </Icon>
                              <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                              <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
                              <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                              <size x="400" y="300" xunits="pixels" yunits="pixels"/>
                          </ScreenOverlay>
                    </Folder>
            </Document>
        </kml>''';

      await client
          .run("echo '$logoKml' > /var/www/html/kml/slave_$logoScreen.kml");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo displayed successfully')),
      );
    } catch (e) {
      print('Error displaying logo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error displaying logo: ${e.toString()}')),
      );
    }
  }

  Future<void> setRefresh(BuildContext context) async {
    try {
      final client = _getClient(context);
      final pw = ref.read(passwordProvider);

      const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
      const replace =
          '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>20<\\/refreshInterval>';
      final command =
          'echo $pw | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

      for (var i = 2; i <= 3; i++) {
        final cmd = command.replaceAll('{{slave}}', i.toString());
        String query = 'sshpass -p $pw ssh -t lg$i \'$cmd\'';

        try {
          await client.run(query);
        } catch (e) {
          print('Error setting refresh for screen $i: $e');
        }
      }

      await relaunchLG(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refresh interval set successfully')),
      );
    } catch (e) {
      print('Error setting refresh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting refresh: ${e.toString()}')),
      );
    }
  }

  Future<void> cleanAll(BuildContext context) async {
    try {
      final client = _getClient(context);

      String query =
          'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';

      const String blankKml = '''<?xml version="1.0" encoding="UTF-8"?>
    <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
      <Document>
      </Document>
    </kml>''';

      for (var i = 1; i <= 3; i++) {
        query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
      }

      await client.run(query);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All screens cleaned successfully')),
      );
    } catch (e) {
      print('Error cleaning screens: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cleaning screens: ${e.toString()}')),
      );
    }
  }

  Future<void> relaunchLG(BuildContext context) async {
    try {
      final client = _getClient(context);

      for (var i = 1; i <= 3; i++) {
        String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} start
          else
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${ref.read(passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";

        await client.run(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref.read(usernameProvider)}/log.txt');
        await client.run(cmd);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liquid Galaxy relaunched successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error relaunching LG: ${e.toString()}')),
      );
    }
  }

  Future<void> shutdownLG(BuildContext context) async {
    try {
      final client = _getClient(context);
      for (var i = 1; i <= 3; i++) {
        await client.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S poweroff"');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shutdown command sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error shutting down: ${e.toString()}')),
      );
    }
  }

  Future<void> displayKml(KMLFile kmlFile) async {
    try {
      final _client = ref.read(sshClientProvider);

      await _client?.execute('echo "playtour=exit" > /tmp/query.txt');
      await _client?.execute('echo "exittour=true" > /tmp/query.txt');
      await _client?.execute('echo "cleanup=true" > /tmp/query.txt');

      await Future.delayed(Duration(seconds: 2));

      final filename = kmlFile.assetPath.split('/').last;
      print("filename: $filename");

      await _client?.execute('chmod 644 /var/www/html/$filename');

      const flyToCommand =
          'echo "flytoview=<LookAt><longitude>72.88528959979917</longitude><latitude>19.0780128323235</latitude><altitude>20.94323213204202</altitude><heading>35.002297190581913546</heading><tilt>0</tilt><range>4334.522587212268</range><altitudeMode>absolute</altitudeMode></LookAt>" > /tmp/query.txt';
      await _client?.execute(flyToCommand);

      await Future.delayed(Duration(seconds: 2));

      await _client
          ?.execute('echo "http://lg1:81/$filename" > /var/www/html/kmls.txt');

      print('KML display command sent for ${kmlFile.name}');
    } catch (e) {
      print('Error displaying KML: $e');
      rethrow;
    }
  }

  // Future<void> displayKml() async {
  //   try {
  //     final _client = ref.read(sshClientProvider);

  //     // Clear existing content
  //     await _client?.execute('echo "playtour=exit" > /tmp/query.txt');
  //     await _client?.execute('echo "exittour=true" > /tmp/query.txt');
  //     await _client?.execute('echo "cleanup=true" > /tmp/query.txt');

  //     await Future.delayed(Duration(seconds: 2));

  //     // First try to verify file exists and has correct permissions
  //     await _client?.execute('chmod 644 /var/www/html/testing.kml');

  //     // Try a different loading approach: Add to kmls.txt first
  //     await _client?.execute(
  //         'echo "/var/www/html/testing.kml" > /var/www/html/kmls.txt');

  //     // Set the view
  //     const flyToCommand =
  //         'echo "flytoview=<LookAt><longitude>72.88528959979917</longitude><latitude>19.0780128323235</latitude><altitude>20.94323213204202</altitude><heading>0.02297190581913546</heading><tilt>0</tilt><range>4334.522587212268</range><altitudeMode>absolute</altitudeMode></LookAt>" > /tmp/query.txt';
  //     await _client?.execute(flyToCommand);

  //     await Future.delayed(Duration(seconds: 2));

  //     // Try these different loading methods one at a time:

  //     // Method 1: Direct load
  //     // await _client?.execute(
  //     //     'echo "loadkml=/var/www/html/testing.kml" > /tmp/query.txt');

  //     // // Method 2: Using network link
  //     await _client?.execute(
  //         'echo "http://lg1:81/testing.kml" > /var/www/html/kmls.txt');

  //     // // Method 3: Using search command
  //     // await _client
  //     //     ?.execute('echo "search=http://lg1:81/testing.kml" > /tmp/query.txt');

  //     print('KML displasday command sent');
  //   } catch (e) {
  //     print('Error displaying KML: $e');
  //     rethrow;
  //   }
  // }

  Future<void> uploadKmlFile(KMLFile kmlFile) async {
    try {
      final _client = ref.read(sshClientProvider);
      final sftp = await _client?.sftp();

      ByteData data = await rootBundle.load(kmlFile.assetPath);
      final bytes = data.buffer.asUint8List();

      final filename = kmlFile.assetPath.split('/').last;
      double uploadProgress = 0.0;

      final remoteFile = await sftp?.open('/var/www/html/$filename',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write);

      var fileSize = bytes.length;

      await remoteFile?.write(Stream.value(bytes), onProgress: (progress) {
        uploadProgress = progress / fileSize;
        print('Upload progress: ${(uploadProgress * 100).toStringAsFixed(2)}%');
      });

      print('${kmlFile.name} uploaded successfully!');
      await displayKml(kmlFile);
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> sendKML(BuildContext context, KMLFile kmlFile) async {
    try {
      await uploadKmlFile(kmlFile);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${kmlFile.name} sent successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending KML: $e')),
        );
      }
    }
  }
}
