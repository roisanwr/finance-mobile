import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi koneksi langsung ke Supabase
  await Supabase.initialize(
    url: 'https://jzwhthrlsepbrihhvfzf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6d2h0aHJsc2VwYnJpaGh2ZnpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1MjU5NzUsImV4cCI6MjA4ODEwMTk3NX0.ruGDddLF7bWb-coch_saWowBHKPSwOsLcsOFBxHJA7I',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau perubahan status otentikasi
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      // Menggunakan pola "when" dari Riverpod untuk menangani 3 kondisi Stream
      home: authState.when(
        data: (data) {
          // Jika ada sesi (session != null), lempar ke Dashboard
          if (data.session != null) {
            return const DashboardDummyScreen();
          }
          // Jika tidak ada sesi, lempar ke layar Login
          return const LoginScreen();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}

// Layar Dummy sementara untuk menandakan login berhasil
class DashboardDummyScreen extends ConsumerWidget {
  const DashboardDummyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Selamat, kamu berhasil masuk ke sistem!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
