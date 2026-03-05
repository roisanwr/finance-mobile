import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/fiat_transaction_repository.dart';
import '../domain/fiat_transaction_model.dart';

// 1. Inject Supabase ke Repository Transaksi
final fiatTransactionRepositoryProvider = Provider<FiatTransactionRepository>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return FiatTransactionRepository(supabase);
});

// 2. Class Notifier untuk mengelola State Transaksi
class FiatTransactionNotifier
    extends AsyncNotifier<List<FiatTransactionModel>> {
  @override
  Future<List<FiatTransactionModel>> build() async {
    return ref.read(fiatTransactionRepositoryProvider).fetchTransactions();
  }

  // Fungsi tambah transaksi yang akan dipanggil dari UI
  Future<void> addTransaction({
    required String walletId,
    required FiatTxType type,
    required double amount,
    String? description,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(fiatTransactionRepositoryProvider);
      await repo.addTransaction(
        walletId: walletId,
        type: type,
        amount: amount,
        description: description,
        date: date,
      );

      // Jika berhasil, tarik ulang riwayat transaksi terbaru
      return repo.fetchTransactions();
    });
  }
}

// 3. Provider utama untuk dipantau UI
final fiatTransactionProvider =
    AsyncNotifierProvider<FiatTransactionNotifier, List<FiatTransactionModel>>(
      () {
        return FiatTransactionNotifier();
      },
    );
