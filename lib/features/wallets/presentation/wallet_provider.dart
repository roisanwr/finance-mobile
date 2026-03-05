import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_model.dart';

// 1. Menyuntikkan Supabase ke Repository Dompet
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return WalletRepository(supabase);
});

// 2. Class Notifier untuk mengelola logika state (Ambil & Tambah Data)
class WalletNotifier extends AsyncNotifier<List<WalletModel>> {
  @override
  Future<List<WalletModel>> build() async {
    // Saat pertama kali dipanggil, otomatis jalankan fetchWallets()
    return ref.read(walletRepositoryProvider).fetchWallets();
  }

  // Fungsi tambah dompet yang akan dipanggil dari UI
  Future<void> addWallet(String name, WalletType type) async {
    // Ubah status layar jadi loading
    state = const AsyncValue.loading();

    // Guard akan menangkap error otomatis jika proses insert gagal
    state = await AsyncValue.guard(() async {
      final repo = ref.read(walletRepositoryProvider);
      await repo.addWallet(name: name, type: type);

      // Jika berhasil, tarik ulang data terbaru dari database
      return repo.fetchWallets();
    });
  }
}

// 3. Provider utama yang akan di-listen (dipantau) oleh layar UI
final walletProvider = AsyncNotifierProvider<WalletNotifier, List<WalletModel>>(
  () {
    return WalletNotifier();
  },
);
