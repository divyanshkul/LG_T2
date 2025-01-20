import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connection_service.dart';
import '../widgets/connection_status.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totalScreensController = TextEditingController();
  bool _isConnecting = false;

  Future<void> _connect() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isConnecting = true);

      try {
        await ConnectionService(ref).connect(
          context,
          ip: _ipController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );
        if (mounted) Navigator.pop(context);
      } finally {
        if (mounted) {
          setState(() => _isConnecting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(connectionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConnectionStatus(isConnected: isConnected),
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          labelText: 'IP Address',
                          labelStyle:
                              TextStyle(color: Colors.white), // Label color
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.computer, color: Colors.white),
                          fillColor: Colors.transparent,
                        ),
                        cursorColor: Colors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter IP address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          fillColor: Colors.transparent,
                        ),
                        cursorColor: Colors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.password, color: Colors.white),
                          fillColor: Colors.transparent,
                        ),
                        cursorColor: Colors.white,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalScreensController,
                        decoration: const InputDecoration(
                          labelText: 'Total Screens in Rig',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.computer, color: Colors.white),
                          fillColor: Colors.transparent,
                        ),
                        cursorColor: Colors.white,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of screen';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (!isConnected) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isConnecting ? null : _connect,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.green,
                        ),
                        child: _isConnecting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Connect',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                  if (isConnected) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            ConnectionService(ref).disconnect(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
