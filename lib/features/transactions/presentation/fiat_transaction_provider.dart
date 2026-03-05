import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/fiat_transaction_repository.dart';
import '../domain/fiat_transaction_model.dart';

final fiatTransactionRepositoryProvider = Provider<FiatTransactionRepository>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return FiatTransactionRepository(supabase);
});

class FiatTransactionNotifier
    extends AsyncNotifier<List<FiatTransactionModel>> {
  @override
  Future<List<FiatTransactionModel>> build() async {
    return ref.read(fiatTransactionRepositoryProvider).fetchTransactions();
  }

  // Parameter diperluas untuk menerima toWalletId dan adminFee
  Future<void> addTransaction({
    required String walletId,
    String? toWalletId,
    required FiatTxType type,
    required double amount,
    double? adminFee, // Opsional untuk biaya admin
    String? description,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(fiatTransactionRepositoryProvider);

      // 1. Eksekusi Transaksi Utama (Masuk/Keluar/Transfer Murni)
      await repo.addTransaction(
        walletId: walletId,
        toWalletId: toWalletId,
        type: type,
        amount: amount,
        description: description,
        date: date,
      );

      // 2. Eksekusi Transaksi Hantu (Biaya Admin) jika ada
      if (type == FiatTxType.TRANSFER && adminFee != null && adminFee > 0) {
        await repo.addTransaction(
          walletId: walletId, // Memotong dari dompet asal
          type: FiatTxType.PENGELUARAN, // Murni dicatat sebagai pengeluaran
          amount: adminFee,
          description: 'Biaya Admin: ${description ?? "Transfer"}',
          date: date,
        );
      }

      return repo.fetchTransactions();
    });
  }
}

final fiatTransactionProvider =
    AsyncNotifierProvider<FiatTransactionNotifier, List<FiatTransactionModel>>(
      () {
        return FiatTransactionNotifier();
      },
    );
