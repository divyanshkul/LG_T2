import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final connectionStateProvider = StateProvider<bool>((ref) => false);
final sshClientProvider = StateProvider<SSHClient?>((ref) => null);

final usernameProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final totalScreensProvider = StateProvider<int>((ref) => 3);

class ConnectionService {
  final WidgetRef ref;

  ConnectionService(this.ref);

  Future<void> connect(
    BuildContext context, {
    required String ip,
    required String username,
    required String password,
    int port = 22,
  }) async {
    try {
      final socket = await SSHSocket.connect(ip, port);
      final client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      await client.authenticated;
      await client.run('echo "test"');

      ref.read(usernameProvider.notifier).state = username;
      ref.read(passwordProvider.notifier).state = password;
      ref.read(sshClientProvider.notifier).state = client;
      ref.read(connectionStateProvider.notifier).state = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected successfully!')),
      );
    } catch (e) {
      ref.read(connectionStateProvider.notifier).state = false;
      ref.read(sshClientProvider.notifier).state = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: ${e.toString()}')),
      );
      rethrow;
    }
  }

  Future<void> disconnect(BuildContext context) async {
    try {
      final client = ref.read(sshClientProvider);
      if (client != null) {
        client.close();
        ref.read(sshClientProvider.notifier).state = null;
        ref.read(connectionStateProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disconnecting: ${e.toString()}')),
      );
    }
  }
}
